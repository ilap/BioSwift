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

public class RNAOnTarget: TargetProtocol, VisitableProtocol {
    public var sequence: String? = "CTGAAATGTTATGGTTGGSG"
    public var complement: String? = "CTGAAATGTTATGGTTGGSG"
    
    public var pam: String? = "CGG"
    public var speciesName: String? = "ID1234"

    // Position
    // + strand --> ^SPACER|PAM
    // - strand --> ^PAM|SPACER --> reversce Compl
    public var strand: String? = "+"
    
    

    public var location: Int? = 145000
    public var length: Int? = 20
    
    public var score: Double? = 0.7
    public var querySequence: String? = ""
    
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
