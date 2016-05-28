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
/// GoF's Abstractfactory pattern for the existing scorefunctions.
///
enum ScoreFunctionType: String {
    case CasOffinder = "Cas-Offinder"
    case CasOffinderEnhanced = "Enhanced Cas-Offinder"
    case BWA = "BWA"
    case Bowtie = "Bowtie"
    case Bowtie2 = "Bowtie2"

    // TODO: Implement all values
    // static let allValues = [CasOffinder, CasOffinderEnhanced, BWA, Bowtie, Bowtie, Bowtie2]
    static let allValues = [CasOffinder]
    static let defaultFunction = CasOffinder
}


//typealias ScoreFunctionFactory = (String) -> TaskParserProtocol

enum ScoreFunctionProvider {
    static func factory(type: ScoreFunctionType) -> TaskParserProtocol { //ScoreFunctionFactory {
        switch type {
        case .CasOffinder:
            return SAMParser()
        // TODO: IMplement these
        /*
        case .CasOffinderEnhanced:
             return BWAParser()
        case .BWA:
             return BWAParser()
        case .Bowtie:
             return BWAParser()
        case .Bowtie2:
             return BWAParser()
        }
        */
        default:
            return SAMParser()
        }

    }
}



