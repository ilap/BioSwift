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

public struct Seq {
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
                    _sequence! .dealloc(Int(strlen(_sequence!) + 1))
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
                // return strlen(_sequence)
                return sequence.characters.count
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
}
