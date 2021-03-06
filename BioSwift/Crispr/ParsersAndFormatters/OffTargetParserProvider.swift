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
///
/// Helper factory for GenericParsers
///
enum ScoreOutputParserProvider {
    static func factory(_ type: RNATargetParserType) -> ParserProtocol {
        switch type {
        case .CasOffinder:
            return CasOffinderOutputParser()
        case .Bowtie:
            return BowtieOutputParser()
        default:
            return CasOffinderOutputParser()
        }
    }
}

///
/// Helper factory for GenericParsers
///
enum ScoreInputFormatterProvider {
    static func factory(_ type: RNATargetParserType, path: String?) -> VisitorProtocol  {
        switch type {
        case .CasOffinder:
            return CasOffinderInputFormatter(path: path)!
        case .Bowtie:
            return BowtieInputFormatter(path: path)!
        default:
            return BowtieInputFormatter(path: path)!
        }
    }
}

///
/// Available OffTarget parsers
///
enum RNATargetParserType: String {
    case CasOffinder = "Cas-Offinder parser"
    // TODO: case CasOffinderOld = "Cas Offinder Old format parser"
    case BWA = "BWA Parser"
    case Bowtie = "Bowtie Parser"
    case Bowtie2 = "Bowtie2 Parser"

    //static let allValues = [CasOffinder, CasOffinderOld, SAM]
    static let allValues = [CasOffinder, BWA, Bowtie, Bowtie2]
    static let defaultFunction = CasOffinder

    var fileExtension: String {
        switch self {
        case CasOffinder: return "cof"
        case BWA: return "bwa"
        case Bowtie: return "bwt"
        case Bowtie2: return "bw2"
        }
    }

    static func getTypeFromExtension (_ ext: String) ->  RNATargetParserType? {
        switch ext {
        case "cof": return CasOffinder
        case "bwa": return BWA
        case "bwt": return Bowtie
        case "bw2": return Bowtie2
        //case "coo": return CasOffinderOld
        default: return nil
        }
    }
}



