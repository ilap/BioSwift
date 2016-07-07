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

/*
 Output file

First column - given query sequence
Second column - FASTA sequence title (if you downloaded it from UCSC or Ensembl, it is usually a chromosome name)
Third column - position of the potential off-target site (same convention with Bowtie)
Forth column - actual sequence located at the position (mismatched bases noted in lowercase letters)
Fifth column - indicates forward strand(+) or reverse strand(-) of the found sequence
Last column - the number of the mismatched bases ('N' in PAM sequence are not counted as mismatched bases)
An example of output file:

GGCCGACCTGTCGCTGACGCNNN chr8 49679    GGgCatCCTGTCGCaGACaCAGG + 5
*/

//
// FIXME: It should be filtered, seed and spacer scored
//
public class CasOffinderOutputParser: GenericParser<OfftargetProtocol> {

    private let recordCount = 6
    /*let seedLength: Int = 10
    let spacerLength: Int = 20
    var pamLength: Int = 3
    var maxMismatch: Int = 6
    
    var targetStart: Int? = nil
    var targetEnd: Int? = nil*/
    
    var designTarget: DesignTargetProtocol? = nil
    var designParameters: DesignParameterProtocol? = nil
    
    override init() {
        print ("OVERRIDE INIT")
        super.init()
    }
    
    init(designTarget: DesignTargetProtocol?, designParameters: DesignParameterProtocol?) {
        self.designTarget = designTarget
        self.designParameters = designParameters
        super.init()
    }
    
    /*init(targetStart: Int? = nil, targetEnd: Int? = nil) {
        print ("NONOVERRIDE")
        if let _ = targetStart {
            self.targetStart = targetStart
        }
        
        if let _ = targetEnd {
            self.targetEnd = targetStart
        }
        // FIXME: Seed length
        super.init()
    }*/
    
    override public func convertToObject(_ array: [String]) throws -> OfftargetProtocol? {

        // We should certain that the array has at least one element, but we
        // cannot be sure whether it's malformed or not.
        // querySequence           modelOranism loc      guide RNA               strand mismatch
        // GGCCGACCTGTCGCTGACGCNNN chr8         49679    GGgCatCCTGTCGCaGACaCAGG +      5
        if (array.count == recordCount) {
            
            let guideLocation = Int(array[2])
            print("INTARGET \(guideLocation), \(designTarget!.location)")
            
            

            if guideLocation > designTarget!.location - designParameters!.spacerLength &&
            guideLocation < designTarget!.location + designTarget!.length + designParameters!.spacerLength {
                print("FILTERED OUT: \(guideLocation)")
                return nil
            }

            
            // Assume it's a CasOffinder parser.
            // FIXME: throw error if the array is malformed.
            // Also use some validation instead of invalid data
            
            // GGCCGACCTGTCGCTGACGCNNN chr8 49679    GGgCatCCTGTCGCaGACaCAGG + 5
            let offtarget = Offtarget()
            

            offtarget.guideRNA = (array[3] as String).uppercased()
            offtarget.querySequence = array[0][0...designParameters!.spacerLength]
            offtarget.modelOrganism = array[1]
            offtarget.rnaPosition = Int(array[2]) ?? Int.min
            offtarget.direction = array[4]
            offtarget.mismatches = Int(array[5]) ?? Int.min
            
            let seed = array[3][designParameters!.spacerLength-designParameters!.seedLength...designParameters!.spacerLength]

            offtarget.seedMismatches = computeSeedMismatches(sequence: seed)

            let seedMismatches = Float(offtarget.seedMismatches!)
            //
            // TODO: Fix the scoring.
            // Currently the score function is based on the number of mismatches.
            //
            
            let N = Float((offtarget.guideRNA?.characters.count)!-designParameters!.pamLength)
            let mismatches = Float(offtarget.mismatches!)
            
            let homology = (mismatches - seedMismatches)/N + seedMismatches/Float(self.maxMismatches)

            offtarget.homology = 1 - homology
            
            
            print ("SEED \(seed): ORIG \(array[3]): \(seedMismatches)::\(offtarget.homology), N \(N), SL \(designParameters!.seedLength)")
            return offtarget

        } else {
            throw BioSwiftError.parserError("Malformed Array: \(array)")
        }
    }

    private func computeSeedMismatches(sequence: String) -> Int {
        let result = sequence.characters.filter({
            let s = String($0).unicodeScalars
            return s[s.startIndex].value >= 97
            //return String($0).lowercased() == String($0)
        }).count
        
        print("REEEEESULT \(result))")
        return result
    }

    override public func parse(_ fileName: String? = nil) {
        print("Cas-Offinder Read")
        super.parse(fileName)


        print("Parsing is done")
    }
}
