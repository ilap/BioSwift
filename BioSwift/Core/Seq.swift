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

