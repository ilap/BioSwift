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
/// Implements Visitable Protocol for formatting PWA inputs.
///
public class BowtieInputFormatter: StreamInputFormatter {


    override public func visit(headerPart: VisitableProtocol) {
        message = headerPart.text
    }
    
    override public func visit(bodyPart: VisitableProtocol) {
        let ontarget = bodyPart as! RNATarget
        message = ">" + ontarget.sourceName! + "-" + String(ontarget.location!) + "-" + String(ontarget.length!)
        message = ontarget.sequence! + ontarget.pam!
    }
    
    override public func visit(footerPart: VisitableProtocol) {
        message = "THIS IS THE ENDXX" + footerPart.text
    }
}
