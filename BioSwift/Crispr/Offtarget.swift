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


public protocol OfftargetProtocol {
    var querySequence: String? { get set }
    var guideRNA: String? { get set }
    var modelOrganism: String? { get set }
    var rnaPosition: Int? { get set }
    var direction: String? { get set }
    var mismatches: Int? { get set }
    var seedMismatches: Int? { get set }
    
    // How the qurey sequnce homologues to the guide/spacer RNA. 
    var homology: Float? { get set }
}


protocol OfftargetResultProtocol: OfftargetProtocol {
    var errorMessages: [String] { get set }
}


class Offtarget: OfftargetResultProtocol {
    var querySequence: String? = nil
    var guideRNA: String? = nil
    var modelOrganism: String? = nil
    var rnaPosition: Int? = nil
    var direction: String? = nil
    var mismatches: Int? = nil
    var seedMismatches: Int? = nil
    var homology: Float? = nil

    var errorMessages: [String] = []
}



