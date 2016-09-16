/*-
 *
 * Author:
 *    Pal Dorogi "ilap" <pal.dorogi@gmail.com>
 *
 * Copyright (c) 2016 Pal Dorogi
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import Foundation

///
/// File utilities to handle files/directories for BioSwift.
///
/// Big-O notations of Swift's Datastructures
/// https://www.raywenderlich.com/123100/collection-data-structures-swift-2
///
public class CrisprUtil {
    
    public var record: SeqRecord
    public var parameters: DesignParameterProtocol
    public var onTargets: [VisitableProtocol?] = []

    
    public init(record: SeqRecord, parameters: DesignParameterProtocol) {
        self.parameters = parameters
        self.record = record
    }
    
    private func getMaskedPAM(_ pamsToMask: [String]) -> String {
        let length = pamsToMask.first?.characters.count

        var result = ""
        
        for col in 0...(length!-1) {

            var colStr = ""

            for row in 0...pamsToMask.count-1 {

                let rowStr = pamsToMask[row]
                let index = rowStr.characters.index(rowStr.startIndex, offsetBy: col)
                let c = rowStr[index]
                colStr.append(c)

            }

            let bases = String(Array(Set(colStr.characters)).sorted())

            result += String(Bases.getBase(bases).rawValue)
        }

        if result.isEmpty {
            assertionFailure("Unexpected error: masked PAM is empty using \(pamsToMask)")
        }

        return result
    }
    
    
    func getPAMsMaskFromPAM(_ pams: [PAMProtocol?], senseStrand: Bool = true, reverseComplement: Bool = false) -> [(PAMProtocol?, Int, Int, Bool)] {
        
        var result: [(PAMProtocol?, Int,Int, Bool)] = []
        
        // Temporary buffer
        let maskBuf = UnsafeMutablePointer<UInt8>(allocatingCapacity: 8)
        let pamBuf = UnsafeMutablePointer<UInt8>(allocatingCapacity: 8)
        // Reset it
        UnsafeMutablePointer<Int>(maskBuf)[0] = 0x0
        UnsafeMutablePointer<Int>(pamBuf)[0] = 0x0
        
        var pamSequence = ""
        for pam in pams {
            //debugPrint("\(__FILE__):\(__LINE__) PAM Sequence is: \(pamSequence)")
            
            // Only N is supported yet as it's hard to mask out the others such as W (A,T and U), R(A,G)
            let maskChar = Bases.n.baseASCII
            
            // UnsafeMutablePointer<Int8>
            
            if reverseComplement {
                pamSequence = (pam.map {$0.sequence}?.reverseComplement())!
            } else {
                pamSequence = pam.map {$0.sequence}!
            }
            let pamMask = UnsafeMutablePointer<UInt8>(strdup(pamSequence))
            let maskedPAM = UnsafeMutablePointer<UInt8>(strdup(pamSequence))
            
            var i = 0
            
            
            while pamMask?[i] != 0 {
                if pamMask?[i] == maskChar {
                    //print("HEUREKA: \(i) : \(pamMask[i])")
                    maskedPAM?[i] = 0x0
                    pamMask?[i] = 0x0
                } else {
                    pamMask?[i] = 0xFF
                }
                i += 1
            }
            
            memcpy(pamBuf, maskedPAM, i)
            memcpy(maskBuf, pamMask, i)
            
            result.append((pam, UnsafeMutablePointer<Int>(pamBuf)[0], UnsafeMutablePointer<Int>(maskBuf)[0], senseStrand))
        }
        
        return result
    }

    
    func getPAMsMask(_ pamSequences: [String], senseStrand: Bool = true) -> [(String, Int, Int, Bool)] {
        
        var result: [(String, Int,Int, Bool)] = []
        
        // Temporary buffer
        let maskBuf = UnsafeMutablePointer<UInt8>(allocatingCapacity: 8)
        let pamBuf = UnsafeMutablePointer<UInt8>(allocatingCapacity: 8)
        // Reset it
        UnsafeMutablePointer<Int>(maskBuf)[0] = 0x0
        UnsafeMutablePointer<Int>(pamBuf)[0] = 0x0
        
        for pamSequence in pamSequences {
            //debugPrint("\(__FILE__):\(__LINE__) PAM Sequence is: \(pamSequence)")
            
            // Only N is supported yet as it's hard to mask out the others such as W (A,T and U), R(A,G)
            let maskChar = Bases.n.baseASCII
            
            // UnsafeMutablePointer<Int8>
            let pamMask = UnsafeMutablePointer<UInt8>(strdup(pamSequence))
            let maskedPAM = UnsafeMutablePointer<UInt8>(strdup(pamSequence))
            
            var i = 0
            
            
            while pamMask?[i] != 0 {
                if pamMask?[i] == maskChar {
                    //print("HEUREKA: \(i) : \(pamMask[i])")
                    maskedPAM?[i] = 0x0
                    pamMask?[i] = 0x0
                } else {
                    pamMask?[i] = 0xFF
                }
                i += 1
            }
            
            memcpy(pamBuf, maskedPAM, i)
            memcpy(maskBuf, pamMask, i)
            
            result.append((pamSequence, UnsafeMutablePointer<Int>(pamBuf)[0], UnsafeMutablePointer<Int>(maskBuf)[0], senseStrand))
        }
        
        return result
    }

    /**
     Retrieve On targets based on the selected PAMs found between the start and 
     end of the design target.
     
     - Parameter pams: PAMs for ontargets.
     - Parameter start: start location of the design target.
     - Parameter end: end location of the design target (start + length).
     
     - Returns: The found on targets (loci of spacer+PAM or PAM+spacer).
    The results are the **location** of **on targets** and **NOT** the location of the
     **PAMs**
     
     - Note: Point editing is not supported yet. Only range is supported.
     */
    public func getPAMOnTargets(_ pams: [PAMProtocol?], start: Int, end: Int) -> [VisitableProtocol?]? {

        guard let seq = record.seq.cSequence else { return nil }
        let pamLength = parameters.pamLength
        
        assert(start >= 0 && end <= self.record.seq.length && start < (end - parameters.pamLength),
               "Start is smaller then End or invalid values for start and end \(end), \(pamLength).\n")
        
        assert(pamLength <= 8,
               "PAM Length must be smaller than 8 in 64 bit system.")
        
        self.onTargets = []
        
        // Initialise on array.
        // Temporary buffer
        let buf = UnsafeMutablePointer<Int>(allocatingCapacity: 2)
        UnsafeMutablePointer<Int>(buf)[0] = 0x0
        UnsafeMutablePointer<Int>(buf)[1] = 0x0
        let seq_buf = UnsafeMutablePointer<Int8>(allocatingCapacity: parameters.spacerLength + 1)
        // Reset it
        UnsafeMutablePointer<Int8>(seq_buf)[parameters.spacerLength] = 0x0
        
        //let pamSequences = pams.map { $0!.sequence }
        
        let maskedPAMs = getPAMsMaskFromPAM(pams) +
            getPAMsMaskFromPAM(pams, senseStrand: false, reverseComplement: true)
    
        var loci = 0
        
        var strand = "-"
        
        for i in start...(end - pamLength) {
            let seq = seq + i
            var tseq = seq
            
            // 1. Get the potential PAM from the sequence
            strncpy(UnsafeMutablePointer<Int8>(buf), seq, pamLength)
            
            // 2. Go through all the masked PAMs
            for (pam, maskedPam, mask, senseStrand) in maskedPAMs {

                // FIXME: Implement other pans than A, G, C, T, N R
                // 3. The the NOT XOR to check whether it's PAM or not. For exammple
                // maskedPam ("NAG") -> "AG"
                // mask -> "0x00FFFF"
                // sequense & mask must be equal to maskedPam
                let seqBits = mask & buf[0]
                
                //print ("MASK: \(String(mask,radix:16)), BUF: \(String(buf[0],radix:16)), BUF: \(String(buf[0]))")
                if seqBits == maskedPam {
                    // TODO:
                    let onTarget = RNATarget()
                    
                    onTarget.score = Double((pam?.survival)!)
                    
                    onTarget.length = parameters.spacerLength
                    
                    if senseStrand {
                        loci = i - parameters.spacerLength
                        strand = "+"
                        tseq -= parameters.spacerLength
                    } else {
                        loci = i + parameters.pamLength
                        strand = "-"
                        tseq += parameters.pamLength
                    }
                    
                    onTarget.strand = strand
                    
                    // Name is the sequence name and guide RNA loci
                    onTarget.sourceName = self.record.id // + "_" + String(loci)
                    onTarget.location = loci
                    
                    // PAM is the pam sequence in the sense/antisense strand
                    let pam = String(cString: UnsafeMutablePointer<Int8>(buf))
                    
                    UnsafeMutablePointer<Int8>(seq_buf)[parameters.spacerLength] = 0x0
                    strncpy(UnsafeMutablePointer<Int8>(seq_buf), tseq, parameters.spacerLength)
                    let seq = String(cString: UnsafeMutablePointer<Int8>(seq_buf))
                    
                    if senseStrand {
                        onTarget.sequence = seq
                        onTarget.complement = seq.complement()
                        onTarget.pam = pam
                    } else {
                        //TODO: Generalise the sense/antisense strands
                        onTarget.complement = seq //.complement()
                        onTarget.sequence = seq.complement() //.reverseComplement()
                        onTarget.pam = pam.complement() //reverseComplement()
                    }
                   
                    #if DEBUG
                        var pre = onTarget.pam
                        var post = onTarget.sequence
                        
                        if onTarget.strand == "-" {
                            let temp = pre
                            pre = post
                            post = temp
                        }
                        
                        // debugPrint ("Prospective on target (\(pre):\(post)) found on \"\(strand)\" strand at loci: \(abs(loci))")
                    #endif

                    self.onTargets.append(onTarget)
                    
                }
            }
        }
        
        // DEBUG print("\"\(self.onTargets.count)\" prospective ontargets found...")
        
        if self.onTargets.isEmpty {
            // Means no any guide RNA candidate in the Target
            return nil
        } else {
            return self.onTargets
        }
        
    }
    
    /*
     "A" = 0001 = 1
     "G" = 0010 = 2
     "C" = 0100 = 4
     "T" = 1000 = 8
     
     "R" = 0011 = "A" "G" = 3
     "Y" = 1100 = "C" "T" = 12
     "S" = 0110 = "G" "C" = 6
     "W" = 1001 = "A" "T" = 9
     "K" = 1010 = "G" "T" = 10
     "M" = 0101 = "A" "C" = 5
     
     "B" = 1110 = "C" "G" "T" = 14
     "D" = 1011 = "A" "G" "T" = 11
     "H" = 1101 = "A" "C" "T" = 13
     "V" = 0111 = "A" "C" "G" = 7
     "N" = 1111 = "A" "G" "C" "T" = 15
     
     */
    static let canonicalPAMs = ["A", "G", "R", "C", "M", "S", "V", "T", "W", "K", "D", "Y", "H", "B", "N"]
    
    
    /*
     FIXME: It does not work like this kind of canonical PAMs: NGAN and NGNG.
     */
    class func computeMaskedPAM(pams: [PAMProtocol?]) -> String {
        // Need to build the canonical PAM for Cas-Offinder.
        let pam_len = (pams[0]?.sequence.characters.count)! - 1
        
        var result = ""
        for i in 0...pam_len { // number of bases
            var mask = 0
            
            for pam in pams {
                let seq: String = (pam?.sequence[Int(i)])!
                let idx = canonicalPAMs.index(of: seq)! + 1
                mask = mask | idx
            }
            result = result + canonicalPAMs[mask-1]
            
        }
        return result
    }


    class internal func pamCompatible(canonicalPAM: String, realPAM: String) -> Bool {
        let pam_len = realPAM.characters.count - 1
        
        var result = 0
        for idx in 0...pam_len {
            let c1: String = canonicalPAM[Int(idx)]
            let c2: String = realPAM[Int(idx)]
            
            let idx1 = canonicalPAMs.index(of: c1)! + 1
            let idx2 = canonicalPAMs.index(of: c2)! + 1
        
            let res = idx1 & idx2
            if res == 0 {
                return false
            }
        }
        
        return true
    }
    
    class func getCompatibleCanonicalPAM(pams: [PAMProtocol?], realPAM: String) -> PAMProtocol? {
        
        for pam in pams {
            if pamCompatible(canonicalPAM: (pam?.sequence)!, realPAM: realPAM) {
                return pam
            }
        }
        return nil
    }
    
    
   public func getOnTargetsLocation(_ pamSequences: [String], start: Int, end: Int) -> [Int]? {
        
        guard let seq = record.seq.cSequence else { return nil }
        let pamLength = pamSequences.first?.characters.count
        
        
        assert(start >= 0 && end <= self.record.seq.length && start < (end - pamLength!),
               "Start is smaller then End or invalid values for start and end \(end), \(pamLength).\n")
        
        var onTargets: [Int]? = []
        
        // Initialise on array.
        // Temporary buffer
        let buf = UnsafeMutablePointer<Int>(allocatingCapacity: 1)
        // Reset it
        UnsafeMutablePointer<Int>(buf)[0] = 0x0
        
        
        let maskedPAMs = getPAMsMask(pamSequences) +
            getPAMsMask(pamSequences.map { $0.reverseComplement() }, senseStrand: false)
    
        var location = 0
        for i in start...(end - pamLength!) {
            let seq = seq + i
            // 1. Get the potential PAM from the sequence
            strncpy(UnsafeMutablePointer<Int8>(buf), seq, pamLength!)
            // 2. Go through all the masked PAMs
            for (_, maskedPam, mask, senseStrand) in maskedPAMs {
                // 3. The the NOT XOR to check whether it's PAM or not. For exammple
                // maskedPam ("NAG") -> "AG"
                // mask -> "0x00FFFF"
                // sequense & mask must be equal to maskedPam
                let seqBits = mask & buf[0]
                
                //print ("MASK: \(String(mask,radix:16)), BUF: \(String(buf[0],radix:16)), OUTBITS: \(String(outBits,radix:16))")
                if seqBits == maskedPam {
                    // TODO: debugPrint ("HEUREKA: location: \(i) PAM: \(pam), Result: \(String.fromCString(UnsafeMutablePointer<Int8>(buf)))")
                    if senseStrand {
                        location = i
                    } else {
                        location = -i
                    }
                    onTargets?.append(Int(location))
                    
                }
            }
        }
        
        if onTargets!.isEmpty {
            return nil
        } else {
            return onTargets
        }
        
    }

    private func printGuideRNAs(_ rnaTargets: [Int], name: String? = nil) {
        
        var organismName = ""
        if let _ = name {
            organismName = name!
        }
        var result: [String] = []
        var validLocation = 0
        var strand = "+"
        var pamPos = 0
        var s = 0
        var e = 0
        
        let tstart = Date()
        for pamLocation in rnaTargets {
            
            //print ("PAMLOCATION \(pamLocation)")
            if  pamLocation >= 0 {
                validLocation = pamLocation
                pamPos = validLocation
                strand = "+"
                s=Int(pamPos) - parameters.spacerLength
                e=Int(pamPos) + parameters.pamLength - 1
                result.append("\(organismName):\(strand):\(s)-\(e):\(record.seq.sequence[s...e])")
            } else {
                validLocation = -pamLocation
                pamPos = validLocation + parameters.pamLength
                strand = "-"
                s=Int(pamPos) - parameters.pamLength
                e=Int(pamPos) + parameters.spacerLength - 1
                result.append("\(organismName):\(strand):\(s)-\(e):\(record.seq.sequence[s...e].complement())")
            }
        }
        let tend = Date()
        let timeInterval = tend.timeIntervalSince(tstart)
        print("Time to evaluate printing gRNA \(timeInterval) seconds")
        
        dump(result)
    }
}
