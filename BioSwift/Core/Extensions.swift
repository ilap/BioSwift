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

public enum FileExtensions: String, CustomStringConvertible {
    case FastaShort = ".fa"
    case FastaLong =  ".fasta"
    //case GenbankShort = ".gb"
    //case GeneralText = ".txt"

    //static let allValues = [.FastaShort, .FastaLog, GenbankShort, GeneralText]
    // TODO: Currently support the Fasta file extensions.
    static let allValues = [FastaShort, FastaLong]

    public var description: String {
        get {
            return self.rawValue
        }
    }
}

public enum BioSwiftError: ErrorProtocol, CustomStringConvertible  {
    case fileError(String)
    case fastaError(String)
    case nucleotideError(String)
    case parserError(String)

    public var description: String {
        get {
            switch (self) {
            case .fileError(let message):
                return message
            case .fastaError(let message):
                return message
            case .nucleotideError(let message):
                return message
            case .parserError(let message):
                return message
            }
        }
    }
}

enum Bases: Character {
    case a = "A"
    case c = "C"
    case g = "G"
    case t = "T"
    case u = "U"
    case r = "R"
    case y = "Y"
    case k = "K"
    case m = "M"
    case s = "S"
    case w = "W"
    case b = "B"
    case d = "D"
    case h = "H"
    case v = "V"
    case n = "N"
    case hyphen = "-"



    var complement: Bases {
        switch self {
        case a: return t
        case c: return g
        case g: return c
        case t: return a
        case r: return y
        case y: return r
        // TODO: not supported yet case W: return "W"

        case n: return n
        //FIXME: Add other values
        default: return n
        }
    }
    static let allValues = [a, c, g, t, r, y, /* TODO: not suppoerted yet W, */ n]

    static func getBase(_ baseString: String) -> Bases {
        switch (baseString) {
        case "AG": return r
        case "CT": return y
        // FIXME:
        default:  return n
        }
    }
    
    var baseASCII: UInt8 {
        switch self {
        case a: return 65
        case c: return 67
        case g: return 71
        case t: return 84
        case r: return 82
        case y: return 89
        // TODO: not supported yet case W: return 87
        case n: return 78
        //FIXME: Add other values
        default: return 0
        }
    }
    var baseBinary: UInt8 {
        switch self {
        case a: return 0b01000001 // Mask out 1
        case c: return 0b01000011 // Mask out 2
        case g: return 0b01000111 // Mask out 4
        case t: return 0b01000100 // Mask out 0
        case r: return 0b01000010 // NO MASK
        case y: return 0b01001001 // NO MASK
        // TODO: not supported yet case W: return 0b01000111 // Mask out 4
        case n: return 0b01001110 // Maks out 8
        //FIXME: Add other values
        default: return 0
        }
    }
    var baseHexa: UInt8 {
        switch self {
        case a: return 0x41
        case c: return 0x43
        case g: return 0x47
        case t: return 0x54
        case r: return 0x52
        case y: return 0x59
        // TODO: not supported yet case W: return 0x57
        case n: return 0x4e
        //FIXME: Add other values
        default: return 0
        }
    }

}

extension String {

    func reverseComplement() -> String {
        let result = self.characters.reversed().map { _complement($0)! }
        return String(result)
    }


    public func complement() -> String {
        let result = self.characters.map { _complement($0)! }
        return String(result)
    }

    func _complement(_ nucleotide: Character?) -> Character? {

        let result = Bases(rawValue: nucleotide!)
        assert (result != nil, "BIOSWITT ERROR: Nucleotide \(nucleotide) is not found!")

        return result!.complement.rawValue
    }
    
    subscript (i: Int) -> Character {
        return self[self.characters.index(self.startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = characters.index(startIndex, offsetBy: r.lowerBound)
        let end = characters.index(start, offsetBy: r.upperBound - r.lowerBound)
        return self[Range(start ..< end)]
    }

    
    subscript (r: CountableClosedRange<Int>) -> String {
        let start = characters.index(startIndex, offsetBy: r.lowerBound)
        let end = characters.index(start, offsetBy: r.upperBound - r.lowerBound)
        //let end = String.CharacterView.
        return self[Range(start ..< end)]
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
    public func format(_ format: String) -> String {
        return String(format: "%\(format)f", self)
    }
}

public func += <T> (lhs: inout [T:Int], rhs: [T:Int]) {
    for (k, i) in rhs {
        lhs[k] = (lhs[k] ?? 0) + i
    }
}
