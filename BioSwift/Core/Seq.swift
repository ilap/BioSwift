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

public class Seq {
    public var sequence : String
    // CString representable of sequence for faster operations
    var _sequence: UnsafeMutablePointer<Int8>? = nil

    public var sequenceType : String
    
    public var initialised: Bool {
        get {
            return _sequence != nil
        }
        set {
            if initialised {
                if newValue == false {
                    _sequence!.deallocateCapacity(Int(strlen(_sequence!)) + 1)
                    _sequence = nil
                }
                return
            }
            
            if newValue == true {
                _sequence = strdup(sequence)
            }
        }
    }
    
    var cSequence : UnsafeMutablePointer<Int8>? {
        if initialised {
            return _sequence
        } else {
            return nil
        }
    }
    public var length : Int {
        get {
            if initialised {

                return Int(strlen(_sequence!))

                // Strlen is faster: 0.01sec versus 8.2sec return sequence.characters.count
            } else {
                return 0
            }
        }
    }
    
    public init (sequence: String = "", sequenceType: String = "fasta") {
        self.sequence = sequence
        self.sequenceType = sequenceType // Currently not used
        
        if sequence != "" {
            initialised = true
        }
    }
    
    //deinit {
     //   _sequence.dealloc(Int(strlen(_sequence) + 1))
        // sequence is a CString from strdup(string) or similar...
    //}
    // First, it ran 5.44sec, then reduced to 1.77sec.
    //
    //public var baseContents: [String:Int] {
    //    return try _baseContents()
    //}
    
    var baseContents: [String:Int] {
        var d: [String:Int] = [:]
        var td: [Int8:Int] = [:]
        if let cstr = self.cSequence { //(self  as NSString).UTF8String
            var c = 0
            //var ch = ""
            while cstr[c] != 0 {
                //ch = String(UnicodeScalar(UInt8(cstr[c])))
                //d[ch] = (d[ch] ?? 0) + 1
                td[cstr[c]] = (td[cstr[c]] ?? 0) + 1
                c += 1
            }
        }
        
        // Check whether it has invalid base letters. e.g. not A, C, G, T, and N (others are not supported yet)
        //let baseSet = Set(Bases.allValues.map { $0.base })
        
        for (key, value) in td {
            let ch = String(UnicodeScalar(UInt8(key)))
            d[ch] = value
            //if !baseSet.contains(ch) {
             //   throw BioError.NucleotideError("ERROR: Unknown base \(ch) found in sequence")
            //}
            
        }
        
        return d
    }
    
    /*func getPAMsMask(_ pamSequences: [String], senseStrand: Bool = true) -> [(String, Int, Int, Bool)] {

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
    
    
    public func getOnTargets(_ pamSequences: [String], start: Int, end: Int) -> [Int]? {
        
        guard let seq = self.cSequence else { return nil }
        let pamLength = pamSequences.first?.characters.count

        
        assert(start >= 0 && end <= self.length && start < (end - pamLength!),
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
    */
    
    public subscript (i: Int) -> Character {
        guard let ch = self.cSequence else { return Character(UnicodeScalar(0)) }
        return Character(UnicodeScalar(UInt8(ch[i])))
    }
    
    public subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    public subscript (r: CountableClosedRange<Int>) -> String {
        let start = r.lowerBound
        let end = start.advanced(by: r.upperBound - r.lowerBound)
        return self.sequence[Range(start ..< end)]

    }
}

