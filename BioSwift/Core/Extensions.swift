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

enum BioError: ErrorType {
    case FastaError(String)
    case NucleotideError(String)
}

enum Bases: Character {
    case A = "A"
    case C = "C"
    case G = "G"
    case T = "T"
    case R = "R"
    case Y = "Y"

    // TODO: not supported yet case W: return "W"
    case N = "N"


    var complement: Bases {
        switch self {
        case A: return T
        case C: return G
        case G: return C
        case T: return A
        case R: return Y
        case Y: return R
            // TODO: not supported yet case R: return "R"
        // TODO: not supported yet case W: return "W"
        case N: return N
        }
    }
    static let allValues = [A, C, G, T, R, Y, /* TODO: not suppoerted yet W, */ N]
    
    var baseASCII: UInt8 {
        switch self {
        case A: return 65
        case C: return 67
        case G: return 71
        case T: return 84
        case R: return 82
        case Y: return 89
        // TODO: not supported yet case R: return 82
        // TODO: not supported yet case W: return 87
        case N: return 78
        }
    }
    var baseBinary: UInt8 {
        switch self {
        case A: return 0b01000001 // Mask out 1
        case C: return 0b01000011 // Mask out 2
        case G: return 0b01000111 // Mask out 4
        case T: return 0b01000100 // Mask out 0
        case R: return 0b01000010 // NO MASK
        case Y: return 0b01001001 // NO MASK
        // TODO: not supported yet case R: return 0b01000010 // Mask out 2
        // TODO: not supported yet case W: return 0b01000111 // Mask out 4
        case N: return 0b01001110 // Maks out 8
        }
    }
    var baseHexa: UInt8 {
        switch self {
        case A: return 0x41
        case C: return 0x43
        case G: return 0x47
        case T: return 0x54
        case R: return 0x52
        case Y: return 0x59
        // TODO: not supported yet case R: return 0x52
        // TODO: not supported yet case W: return 0x57
        case N: return 0x4e
        }
    }

}

extension String {

    func reverseComplement() -> String {
        let result = self.characters.reverse().map { _complement($0)! }
        return String(result)
    }


    public func complement() -> String {
        let result = self.characters.map { _complement($0)! }
        return String(result)
    }

    func _complement(nucleotide: Character?) -> Character? {

        let result = Bases(rawValue: nucleotide!)
        assert (result != nil, "BIOSWITT ERROR: Nucleotide \(nucleotide) is not found!")

        return result!.complement.rawValue
    }
    
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