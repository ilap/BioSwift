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
// Use http://stackoverflow.com/questions/24581517/read-a-file-url-line-by-line-in-swift for parsing
// http://stackoverflow.com/questions/26674182/streamreader-for-server-urls
// http://stackoverflow.com/questions/24097826/read-and-write-data-from-text-file
// Benchmarking short sequence mapping tools - All Exisiting tool
// http://bmcbioinformatics.biomedcentral.com/articles/10.1186/1471-2105-14-184

public class SeqRecord {
    var _gc_content : Bool = true
    var _bases : [String:Int]? = nil
    var initialised : Bool {
        get {
            return seq.initialised
        }
        set {
            seq.initialised = newValue
        }
    }
    
    public var id : String
    public var description : String = ""
    
    public var length : Int {
        get {
            return seq.length
        }
    }

    public var seq: Seq
    public var gcContent : Double {
        if seq.initialised {
            return Double(bases!["C"]! + bases!["G"]!) / Double(length)
        } else {
            return 0.0
        }
    }
    
    public var hash: Int {
        get {
            return seq.sequence.hash
        }
    }
    
    //TODO: Should be updated when sequence modified
    public var bases : [String:Int]? {
        get {
            if !initialised {
                return nil
            }
            if _bases == nil {
                //_bases =  seq.sequence.baseContents
                _bases = seq.baseContents
            }
            return _bases!
        }
    }
    
    public init (id: String) {
        self.id = id
        self.seq = Seq()
    }
    
    func append (sequence: String) {
        
        seq.sequence += sequence
    }
    
    
    /*public func getPAMs(pam: [String], start: Int, end: Int) -> [String:[Int]]?{
        var d: [String:[Int]] = [:]
        
        // or strdup(seq.sequence)
        //var cstr = (seq.sequence as NSString).UTF8String
        guard let cstr = seq.cSequence else { return nil }
        
        // 
        var c = 0
        var ch = ""
        /* while cstr[c] != 0 {
         ch = String(UnicodeScalar(UInt8(cstr[c])))
         d[ch] = (d[ch] ?? 0) + 1
         c += 1
         }*/
        return d
    }*/
    
    public subscript (i: Int) -> Character {
        return seq[i]
    }
    
    public subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
}