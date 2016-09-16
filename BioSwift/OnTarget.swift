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


public class RNATarget: TargetProtocol, VisitableProtocol {
    public var sourceName: String? = "ID1234"
    
    public var sequence: String? = "CTGAAATGTTATGGTTGGSG"
    public var complement: String? = "CTGAAATGTTATGGTTGGSG"
    public var pam: String? = "CGG"

    // On-target sequence
    // Store the query sequence on which the sequence is compared
    // e.g. score based on this comparison
    public var guideSequence: String? = nil
    public var guidePam: String? = nil
    
    // Position
    // + strand --> ^SPACER|PAM
    // - strand --> ^PAM|SPACER --> compl
    public var strand: String? = nil
    

    public var location: Int? = nil
    public var length: Int? = nil
    
    public var score: Double? = nil

    // These below are currently not used
    public var mismatch: Int? = nil
    public var seedMismatch: Int? = nil
    
    //
    // Visitor protocol
    //
    public var text: String {
        get {
            return sequence!
        }
        set {
            sequence! = newValue
        }
    }
    
    public func accept(visitor: VisitorProtocol) {
        visitor.visit(bodyPart: self)
    }
}
