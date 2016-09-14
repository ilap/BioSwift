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
/// Implements Visitor protocol
///
public class StreamInputFormatter: VisitorProtocol {
    
    public var fileName: String
    private var streamWriter: StreamWriter?
    
    private let template = "rna_input_file.XXXXXX"
    
    var _message: String = ""
    public var message: String {
        get {
            // Only last line is supported.
            return _message
        }
        
        set {
            _message = newValue
            streamWriter?.writeLine(message: _message)
        }
    }
    
    public init?(path: String? = nil) {

        if let streamWriter = StreamWriter(path: path) {
            self.streamWriter = streamWriter
            self.fileName = streamWriter.fileName
        } else {
            // FIXME: Throw and error
            return nil
        }
    }
    
    deinit {
        streamWriter?.close()
    }
    
    public func visit(headerPart: VisitableProtocol) {
        // FIXME: Throw and error as this code should not be reachead..
        assertionFailure("This code should not be reachead" + #file + ":" + String(#line))
    }
    
    public func visit(bodyPart: VisitableProtocol) {
        // FIXME: Throw and error as this code should not be reachead..
        assertionFailure("This code should not be reachead" + #file + ":" + String(#line))
    }
    
    public func visit(footerPart: VisitableProtocol) {
        // FIXME: Throw and error as this code should not be reachead..
        assertionFailure("This code should not be reachead" + #file + ":" + String(#line))
    }

    public func visit(parent: VisitableProtocol) {
        // FIXME: Throw and error as this code should not be reachead..
        assertionFailure("This code should not be reachead" + #file + ":" + String(#line))
    }
}
