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


public class BowtieOutputParser: GenericParser<OfftargetProtocol> {
    //gi|349596987|gb|CP002905.1|:+:249965-249987     +       gi|349596987|gb|CP002905.1|     189488  ATTTCTTCCAGGAAGCTACGTGA IIIIIIIIIIIIIIIIIIIIIII 1
    private let recordCount = 7

    override public func convertToObject(_ records: [String]) throws -> OfftargetProtocol? {

        // We should certain that the array has at leas one element, but we
        // cannot be sure whether it's malformed or not.

        if (records.count == recordCount) {
            // Assume it's a CasOffinder parser.
            // FIXME: throw error if the array is malformed.
            // Also use some validation instead of invalid data
            let offtarget = Offtarget2()

            /*offtarget.guideRNA = records[4]
            offtarget.modelOrganism = records[2]
            offtarget.rnaPosition = Int(records[3]) ?? Int.min
            offtarget.direction = records[5]
            offtarget.mismatches = Int(records[6]) ?? Int.min
            // TODO: Fix the scoring.
            offtarget.score = 1 - Double(offtarget.mismatches!) / Float((offtarget.guideRNA?.characters.count)!)
            */
            return offtarget

        } else {
            throw BioSwiftError.parserError("Malformed Array: \(records)")
        }
    }

    override public func parse(_ fileName: String? = nil) {
        //XXX: ilap print("Cas-Offinder Read")
        super.parse(fileName)
        
        
        print("Parsing is done")
    }
}
