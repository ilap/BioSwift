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
public class CasOffinderOutputParser: GenericParser<TargetProtocol> {

    private let recordCount = 6
    var designTarget: DesignTargetProtocol? = nil
    var designParameters: DesignParameterProtocol? = nil
    
    override init() {
        super.init()
    }
    
    init(designTarget: DesignTargetProtocol?, designParameters: DesignParameterProtocol?) {
        self.designTarget = designTarget
        self.designParameters = designParameters
        super.init()
    }
    
    override public func convertToObject(_ array: [String]) throws -> TargetProtocol? {

        // We should certain that the array has at least one element, but we
        // cannot be sure whether it's malformed or not.
        // For scoring we need the affinity of the current PAM
        // querySequence           modelOranism loc      guide RNA               strand mismatch
        // GGCCGACCTGTCGCTGACGCNNN chr8         49679    GGgCatCCTGTCGCaGACaCAGG +      5
        if (array.count != recordCount) {
            throw BioSwiftError.parserError("Malformed Array: \(array)")
        }

        let guideLocation = Int(array[2])
        // DEBUG print("INTARGET \(guideLocation), \(designTarget!.location)")
        
        // Filter out first, as targets in DesignTarget are not considered.
        if guideLocation > designTarget!.location - designParameters!.spacerLength &&
            guideLocation < designTarget!.location + designTarget!.length + designParameters!.spacerLength {
            // print("FILTERED OUT: \(guideLocation)")
            return nil
        }

            
        // CasOffinder parser.
        // FIXME: throw error if the array is malformed.
        // Also use some validation instead of invalid data
            
        // GGCCGACCTGTCGCTGACGCNNN chr8 49679    GGgCatCCTGTCGCaGACaCAGG + 5
        let offtarget = Offtarget()
        //let mismatches = Int(array[5]) ?? Int.min



        offtarget.length = array[3].characters.count
        let sequence = array[3][0...designParameters!.spacerLength]
        offtarget.sequence = sequence.uppercased()
        offtarget.pam = array[3][designParameters!.spacerLength...offtarget.length!]
        offtarget.querySequence = array[0][0...designParameters!.spacerLength]
        
        offtarget.speciesName = array[1]
        offtarget.strand = array[4]
        offtarget.location = Int(array[2]) ?? Int.min

        // FIXME: Seed is currently not used
        // In the final fersion the seed part of the gRNA do not have penalty.
        // let seed = array[3][designParameters!.spacerLength-designParameters!.seedLength...designParameters!.spacerLength]

            
        // if mismatech 0, then we do not needt to do anything
        offtarget.score = 1.0 //Assume 100% homology
        offtarget.score = computeOfftargetScore(sequence: sequence, initialScore: offtarget.score!)

            
        // DEBUG print ("score \(offtarget.score): SEQ \(offtarget.sequence): PAM: \(offtarget.pam)::\(offtarget.score), SL \(designParameters!.seedLength)")
        return offtarget

    }
    
    private func computeOfftargetScore(sequence: String, initialScore: Double) -> Double {
        
        let length = Double(sequence.characters.count)
        var score = initialScore
        
        for (idx, base) in sequence.characters.enumerated() {
            // 97 means lowercase
            let s = String(base).unicodeScalars
            
            if s[s.startIndex].value >= 97 {
                score = score *  Double(pow(Double(length), -(Double(idx+1)/Double(length))))
            }
        }
        
        return score
    }
    override public func parse(_ fileName: String? = nil) {
        //XXX: ilap print("Cas-Offinder Read")
        super.parse(fileName)
        //XXX: ilap print("Parsing is done")
    }
}
