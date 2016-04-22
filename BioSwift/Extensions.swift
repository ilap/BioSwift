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

/*extension SeqIO : SequenceType {
 public func generate() -> AnyGenerator<[SeqRecord]> {
 return AnyGenerator {
 return self.getRecords()
 }
 }
 }*/

extension String {
    
    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = startIndex.advancedBy(r.startIndex)
        let end = start.advancedBy(r.endIndex - r.startIndex)
        return self[Range(start ..< end)]
    }
    
    // ~5sec for 4 million bases
    public var baseContents: [String:Int] {
        var d: [String:Int] = [:]
        
        var cstr = (self  as NSString).UTF8String
        var c = 0
        var ch = ""
        while cstr[c] != 0 {
            ch = String(UnicodeScalar(UInt8(cstr[c])))
            d[ch] = (d[ch] ?? 0) + 1
            c += 1
        }
        return d
    }
    
   /* // ~16sec for 4 million bases
   public var baseContents: [String:Int] {
        var d: [String:Int] = [:]
        enumerateSubstringsInRange(characters.indices, options: .ByComposedCharacterSequences) { base, _, _, _ in
            guard let base = base?.uppercaseString else { return }
            d[base] = (d[base] ?? 0) + 1
        }
        return d
    }

    public var sortBaseContents: [(word: String, count: Int)] {
        return baseContents.sort{ $0.0 < $1.0 }.map{ (word: $0, count: $1) }
    }
 */
}

extension Double {
    public func format(format: String) -> String {
        return String(format: "%\(format)f", self)
    }
}

public func += <T> (inout lhs: [T:Int], rhs: [T:Int]) {
    for (k, i) in rhs {
        lhs[k] = (lhs[k] ?? 0) + i
    }
}