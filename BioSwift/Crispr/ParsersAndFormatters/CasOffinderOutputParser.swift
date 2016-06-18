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

public class CasOffinderOutputParser: GenericParser<OfftargetProtocol> {

    //#Bulge type	crRNA	DNA	Chromosome	Position	Direction	Mismatches	Bulge Size
    //X	GTCGCTGACGCTGGCGCCGTNGG	GTCGCTGAtGgTGGtGgCGcGGG	E.coli_K-12	255142	- 5	0
    private let recordCount = 8

    override public func convertToObject(_ array: [String]) throws -> OfftargetProtocol? {

        // We should certain that the array has at leas one element, but we 
        // cannot be sure whether it's malformed or not.

        if (array.count == recordCount) {
            // Assume it's a CasOffinder parser.
            // FIXME: throw error if the array is malformed.
            // Also use some validation instead of invalid data
            let offtarget = Offtarget()

            offtarget.guideRNA = array[1]
            offtarget.modelOrganism = array[3]
            offtarget.rnaPosition = Int(array[4]) ?? Int.min
            offtarget.direction = array[5]
            offtarget.mismatches = Int(array[6]) ?? Int.min
            // TODO: Fix the scoring.
            offtarget.score = 1 - Float(offtarget.mismatches!) / Float((offtarget.guideRNA?.characters.count)!)

            return offtarget

        } else {
            throw BioSwiftError.parserError("Malformed Array: \(array)")
        }
    }

    override public func parse(_ fileName: String? = nil) {
        print("Cas-Offinder Read")
        super.parse(fileName)


        print("Parsing is done")
    }
}
