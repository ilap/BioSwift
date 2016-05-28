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

///
/// File utilities to handle files/directories for BioSwift.
///
/// Big-O notations of Swift's Datastructures
/// https://www.raywenderlich.com/123100/collection-data-structures-swift-2
public class CrisprUtil {

    var record: SeqRecord
    var usedPAMs: [String]
    var allPAMs: [String]

    var maskedPAM: String = ""

    public init(record: SeqRecord, usedPAMs: [String], allPAMs: [String] ) {
        self.record = record
        self.usedPAMs = usedPAMs
        self.allPAMs = allPAMs

        self.maskedPAM = getMaskedPAM(allPAMs)

    }

    private func getMaskedPAM(pamsToMask: [String]) -> String {
        let length = pamsToMask.first?.characters.count

        var result = ""
        for col in Range(0...length!-1) {

            var colStr = ""

            for row in Range(0...pamsToMask.count-1) {

                let rowStr = pamsToMask[row]
                let index = rowStr.startIndex.advancedBy(col)
                let c = rowStr[index]
                colStr.append(c)

            }

            let bases = String(Array(Set(colStr.characters)).sort())

            result += String(Bases.getBase(bases).rawValue)
        }

        if result.isEmpty {
            assertionFailure("Unexpected error: masked PAM is empty using \(allPAMs)")
        }

        return result
    }

    private func getOnTargets() {

    }

    func getScoredOfftargets(targetLoci: Int, targetLength: Int, scoringFunction: ScoringFunction? = nil) {

        if let _ = scoringFunction {
            scoringFunction!.runOn(record)
        }
    }

}

protocol ScoringFunction {
    func parse()
    func runOn(record: SeqRecord)
}