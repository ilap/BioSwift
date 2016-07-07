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
    
    var record: SeqRecord
    var parameters: DesignParameterProtocol? = nil
    
    public var onTargets: [VisitableProtocol?] = []
    
    var seq: Seq

    //FIXME: var usedPAMs: [String]
    //var allPAMs: [String]
    
    public var seedLength: Int = 10
    public var spacerLength: Int = 20
    public var pamLength: Int = 3

    //var maskedPAM: String = ""
    
    public init(record: SeqRecord, parameters: DesignParameterProtocol) {
        self.parameters = parameters
        self.record = record
        self.seq = self.record.seq
        //self.allPAMs = parameters.pams.map { ($0?.sequence)! }
        
        //self.pamLength = (self.allPAMs.first?.characters.count)!
        
        //self.maskedPAM = getMaskedPAM(self.allPAMs)
    }

    public init(record: SeqRecord, allPAMs: [String] ) {
        self.record = record
        self.seq = self.record.seq
        // FIXME: self.usedPAMs = usedPAMs
        //self.allPAMs = allPAMs
        
        self.pamLength = allPAMs[0].characters.count

        //self.maskedPAM = getMaskedPAM(allPAMs)

    }
    
    public init(record: SeqRecord, allPAMs: [PAMProtocol?] ) {
        self.record = record
        self.seq = self.record.seq
        
        // FIXME: self.usedPAMs = usedPAMs
        ////self.allPAMs = allPAMs.map {
         //   $0!.sequence
        //}
        
        //self.pamLength = self.allPAMs[0].characters.count
        //self.maskedPAM = getMaskedPAM(self.allPAMs)
    }

    ////private func getMaskedPAM(_ pamsToMask: [PAMProtocol?]) -> String {
    //   return getMaskedPAM(pamsToMask.map {
    //           $0!.sequence
    //   })
    //}
    
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

        
        guard let seq = seq.cSequence else { return nil }
        let pamLength = parameters?.pamLength
        
        assert(start >= 0 && end <= self.seq.length && start < (end - pamLength!),
               "Start is smaller then End or invalid values for start and end.")
        
        assert(pamLength <= 8,
               "PAM Length must be smaller than 8 in 64 bit system.")
        
        self.onTargets = []
        
        // Initialise on array.
        // Temporary buffer
        let buf = UnsafeMutablePointer<Int>(allocatingCapacity: 1)
        UnsafeMutablePointer<Int>(buf)[0] = 0x0
        
        let seq_buf = UnsafeMutablePointer<Int8>(allocatingCapacity: spacerLength + 1)
        // Reset it
        UnsafeMutablePointer<Int8>(seq_buf)[spacerLength] = 0x0
        
        //let pamSequences = pams.map { $0!.sequence }
        
        let maskedPAMs = getPAMsMaskFromPAM(pams) +
            getPAMsMaskFromPAM(pams, senseStrand: false, reverseComplement: true)
        
        var loci = 0
        
        var strand = "-"
        for i in start...(end - pamLength!) {
            let seq = seq + i
            var tseq = seq
            // 1. Get the potential PAM from the sequence
            strncpy(UnsafeMutablePointer<Int8>(buf), seq, pamLength!)
            // 2. Go through all the masked PAMs
            for (pam, maskedPam, mask, senseStrand) in maskedPAMs {
                // 3. The the NOT XOR to check whether it's PAM or not. For exammple
                // maskedPam ("NAG") -> "AG"
                // mask -> "0x00FFFF"
                // sequense & mask must be equal to maskedPam
                let seqBits = mask & buf[0]
                
                //print ("MASK: \(String(mask,radix:16)), BUF: \(String(buf[0],radix:16)), BUF: \(String(buf[0]))")
                if seqBits == maskedPam {
                    // TODO:
                    let onTarget = RNAOnTarget()
                    
                    onTarget.score = (pam?.survival)!
                    onTarget.strand = strand
                    onTarget.length = spacerLength
                    
                    if senseStrand {
                        loci = i - spacerLength
                        strand = "+"
                        tseq -= spacerLength
                    } else {
                        loci = -i
                        strand = "-"
                        tseq += pamLength!
                    }
                    
                    
                    // Name is the sequence name and guide RNA loci
                    onTarget.name = self.record.id + "_" + String(loci)
                    onTarget.position = loci
                    
                    // PAM is the pam sequence in the sense/antisense strand
                    let pam = String(cString: UnsafeMutablePointer<Int8>(buf))
                    
                    UnsafeMutablePointer<Int8>(seq_buf)[spacerLength] = 0x0
                    strncpy(UnsafeMutablePointer<Int8>(seq_buf), tseq, spacerLength)
                    let seq = String(cString: UnsafeMutablePointer<Int8>(seq_buf))
                    
                    if senseStrand {
                        onTarget.sequence = seq
                        onTarget.pam = pam
                    } else {
                        //TODO: Generalise the sense/antisense strands
                        onTarget.sequence = seq.reverseComplement()
                        onTarget.pam = pam.reverseComplement()
                    }
                   
                    #if DEBUG
                        var pre = onTarget.pam
                        var post = onTarget.sequence
                        
                        if onTarget.strand == "-" {
                            let temp = pre
                            pre = post
                            post = temp
                        }
                        
                        print ("Prospective on target (\(pre):\(post)) found on \"\(strand)\" strand at loci: \(abs(loci))")
                    #endif

                    self.onTargets.append(onTarget)
                    
                }
            }
        }
        
        print("\"\(self.onTargets.count)\" prospective ontargets found...")
        
        if self.onTargets.isEmpty {
            return nil
        } else {
            return self.onTargets
        }
        
    }
    
   /* public func getOnTargetsX(_ pamSequences: [String], start: Int, end: Int) -> [VisitableProtocol?]? {
        
        guard let seq = seq.cSequence else { return nil }
        let pamLength = pamSequences.first?.characters.count
        
        
        assert(start >= 0 && end <= self.seq.length && start < (end - pamLength!),
               "Start is smaller then End or invalid values for start and end.")
        
        assert(pamLength <= 8,
               "PAM Length must be smaller than 8 in 64 bit system.")

        self.onTargets = []
        
        // Initialise on array.
        // Temporary buffer
        let buf = UnsafeMutablePointer<Int>(allocatingCapacity: 1)
        UnsafeMutablePointer<Int>(buf)[0] = 0x0
        
        let seq_buf = UnsafeMutablePointer<Int8>(allocatingCapacity: spacerLength + 1)
        // Reset it
        UnsafeMutablePointer<Int8>(seq_buf)[spacerLength] = 0x0

        
        
        let maskedPAMs = getPAMsMask(pamSequences) +
            getPAMsMask(pamSequences.map { $0.reverseComplement() }, senseStrand: false)
        
        var location = 0
        var strand = "-"
        for i in start...(end - pamLength!) {
            let seq = seq + i
            var tseq = seq
            // 1. Get the potential PAM from the sequence
            strncpy(UnsafeMutablePointer<Int8>(buf), seq, pamLength!)
            // 2. Go through all the masked PAMs
            for (_, maskedPam, mask, senseStrand) in maskedPAMs {
                // 3. The the NOT XOR to check whether it's PAM or not. For exammple
                // maskedPam ("NAG") -> "AG"
                // mask -> "0x00FFFF"
                // sequense & mask must be equal to maskedPam
                let seqBits = mask & buf[0]
                
                //print ("MASK: \(String(mask,radix:16)), BUF: \(String(buf[0],radix:16)), BUF: \(String(buf[0]))")
                if seqBits == maskedPam {
                    // TODO: 
                    
                    if senseStrand {
                        location = i - spacerLength
                        strand = "+"
                        tseq -= spacerLength
                    } else {
                        location = -i
                        strand = "-"
                        tseq += pamLength!
                    }
                    let onTarget = RNAOnTarget()
                    onTarget.name = self.record.id
                    onTarget.pam = String(cString: UnsafeMutablePointer<Int8>(buf))
                    UnsafeMutablePointer<Int8>(seq_buf)[spacerLength] = 0x0
                    
                    strncpy(UnsafeMutablePointer<Int8>(seq_buf), tseq, spacerLength)
                    
                    onTarget.sequence = String(cString: UnsafeMutablePointer<Int8>(seq_buf))
                    debugPrint ("HEUREKAXX: location: \(location), Strand: \(strand), PAM: \(onTarget.pam):\(onTarget.sequence)")
                    onTarget.length = spacerLength
                    onTarget.position = location
                    onTarget.strand = strand
                    
                    self.onTargets.append(onTarget)
                    
                }
            }
        }
        
        if self.onTargets.isEmpty {
            return nil
        } else {
            return self.onTargets
        }
        
    }

    */

   public func getOnTargetsLocation(_ pamSequences: [String], start: Int, end: Int) -> [Int]? {
        
        guard let seq = seq.cSequence else { return nil }
        let pamLength = pamSequences.first?.characters.count
        
        
        assert(start >= 0 && end <= self.seq.length && start < (end - pamLength!),
               "Start is smaller then End or invalid values for start and end.")
        
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
 


    func getScoredOfftargets(_ targetLoci: Int, targetLength: Int, scoringFunction: ScoringFunction? = nil) {

        if let _ = scoringFunction {
            scoringFunction!.runOn(record)
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
                s=Int(pamPos) - spacerLength
                e=Int(pamPos) + pamLength - 1
                result.append("\(organismName):\(strand):\(s)-\(e):\(record.seq.sequence[s...e])")
            } else {
                validLocation = -pamLocation
                pamPos = validLocation + pamLength
                strand = "-"
                s=Int(pamPos) - pamLength
                e=Int(pamPos) + spacerLength - 1
                result.append("\(organismName):\(strand):\(s)-\(e):\(record.seq.sequence[s...e].complement())")
            }
        }
        let tend = Date()
        let timeInterval = tend.timeIntervalSince(tstart)
        print("Time to evaluate printing gRNA \(timeInterval) seconds")
        
        dump(result)
        //print(result.joinWithSeparator("\n"))
        
    }

    
   /* public func XwriteOntargetsAsFastaFile(_ usedPAMs: [String], start: Int, end: Int) -> String? {
        
          var result: String?
        
        let temp = try! URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("rna_input_file.XXXXXX")
        
        var buf = [Int8](repeating: 0, count: Int(PATH_MAX))
        (temp as NSURL).getFileSystemRepresentation(&buf, maxLength: buf.count)
        
        let fd = mkstemp(&buf)
        
        var url: URL? = nil
        
        if fd != -1 {
            
            // Create URL from file system string:
            url = URL(fileURLWithFileSystemRepresentation: buf, isDirectory: false, relativeToURL: nil)
            
            if let temp_url = url, let _ = temp_url.path {
                result = temp_url.path
                
                print("TEMPFILE IS: ", temp_url.path!)
            } else {
                print("NO URL")
            }
            
        } else {
            print("FATAL ERROR: " + String(strerror(errno)))
        }
        
        let ontargets = getOnTargetsLocation(usedPAMs, start: start, end: end)
        
        writeGuideRNAToURL(url!, rnaTargets: ontargets!, name: record.id)
 
        close(fd)
        
        return result
    
    }
    
    private func writeGuideRNAToURL(_ url: URL, rnaTargets: [Int], name: String? = nil) {
        
        print ("DOOOOOOOOOIIIIIIIIIIIIIT")
        
        
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

        var data: Data = "STRING.....".data(using: String.Encoding.utf8)!
        let resultData = NSMutableData()

        var dataStr: NSString = ""
        
        let tstart = Date()
        
        for pamLocation in rnaTargets {
            
            //print ("PAMLOCATION \(pamLocation)")

            if  pamLocation >= 0 {
                validLocation = pamLocation
                pamPos = validLocation
                strand = "+"
                s=Int(pamPos) - spacerLength
                e=Int(pamPos) + pamLength - 1
                //result.append("\(organismName):\(strand):\(s)-\(e):\(record.seq.sequence[s...e])")
                dataStr = "\(organismName):\(strand):\(s)-\(e):\(record.seq.sequence[s...e])\n" as NSString
                data = dataStr.data(using: String.Encoding.utf8.rawValue)!
                resultData.append(data)
                
            } else {
                validLocation = -pamLocation
                pamPos = validLocation + pamLength
                strand = "-"
                s=Int(pamPos) - pamLength
                e=Int(pamPos) + spacerLength - 1
                
                dataStr = "\(organismName):\(strand):\(s)-\(e):\(record.seq.sequence[s...e].complement())\n" as NSString
                
                
                data = dataStr.data(using: String.Encoding.utf8.rawValue)!
                resultData.append(data)

            }
            //print ("XXXX: \(dataStr)")
            
            //writeToURL(url, options: .AtomicWrite)
        }
        try? resultData.write(to: url, atomically: false)
        
        let tend = Date()
        let timeInterval = tend.timeIntervalSince(tstart)
        print("Time to evaluate printing gRNA \(timeInterval) seconds")
        
        //dump(result)
        //print(result.joinWithSeparator("\n"))
        
    }*/
}


protocol ScoringFunction {
    func parse()
    func runOn(_ record: SeqRecord)
}
