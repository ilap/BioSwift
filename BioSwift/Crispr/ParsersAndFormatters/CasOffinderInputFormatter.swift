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
 Input file
 
 First line - path of chromosomes FASTA files
 Second line - desired pattern including PAM sequence
 Third (or more) line - query sequences with maximum mistmatched numbers, 
 seperated by spaces. (The length of the desired pattern and the query sequences 
 should be the same!)
 
 Input format
 /var/chromosomes/human_hg19
 NNNNNNNNNNNNNNNNNNNNNRG
 GGCCGACCTGTCGCTGACGCNNN 5
 CGCCAGCGTCAGCGACAGGTNNN 5
 ACGGCGCCAGCGTCAGCGACNNN 5
 GTCGCTGACGCTGGCGCCGTNNN 5
 ...
 
 Output file
 
 First column - given query sequence
 Second column - FASTA sequence title (if you downloaded it from UCSC or Ensembl, it is usually a chromosome name)
 Third column - position of the potential off-target site (same convention with Bowtie)
 Forth column - actual sequence located at the position (mismatched bases noted in lowercase letters)
 Fifth column - indicates forward strand(+) or reverse strand(-) of the found sequence
 Last column - the number of the mismatched bases ('N' in PAM sequence are not counted as mismatched bases)
 An example of output file:
 
 GGCCGACCTGTCGCTGACGCNNN chr8 49679    GGgCatCCTGTCGCaGACaCAGG + 5
 GGCCGACCTGTCGCTGACGCNNN chr8 517739   GcCCtgCaTGTgGCTGACGCAGG + 5
 Reference: http://www.rgenome.net/cas-offinder/portable
 */
class CasOffinderInputFormatter: StreamInputFormatter {
    
    override func visit(headerPart: VisitableProtocol) {
        message = headerPart.text
    }
    
    override func visit(bodyPart: VisitableProtocol) {

        if bodyPart is RNATarget {
            let ontarget = bodyPart as! RNATarget
            //message = ">" + ontarget.name + "-" + String(ontarget.position) + "-" + String(ontarget.length)
            let pam = String(repeating: "N" as Character, count: (ontarget.pam?.characters.count)!)
            
            // FIXME: The "7" should come form parameter
            message = ontarget.sequence! + pam + " 7"
        } else {
            message = bodyPart.text
        }
    }
    
    override func visit(footerPart: VisitableProtocol) {
        message = "THIS IS THE ENDXX" + footerPart.text
    }
}

///
/// CasOffinder reqires a genome name and initial mask sequence
/// Input format
/// /var/chromosomes/human_hg19
/// NNNNNNNNNNNNNNNNNNNNNRG
/// GGCCGACCTGTCGCTGACGCNNN 5
class CasOffinderInitialSequence: VisitableProtocol {
    var text: String
    var genome: String
    var spacer: String
    
    init(genome: String, spacerLength: Int, maskedPAM: String) {
        self.genome = genome
        
        self.spacer = String(repeating: "N" as Character, count: spacerLength)
                        + maskedPAM
        self.text = spacer
    }
    
    func accept(visitor: VisitorProtocol) {
        self.text = genome
        visitor.visit(headerPart: self)
        self.text = spacer
        visitor.visit(bodyPart: self)
    }
}
