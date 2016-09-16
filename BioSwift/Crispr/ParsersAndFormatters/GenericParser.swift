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

public class GenericParser<T>: ParserProtocol {
    
    var results: [T] = []
    private var fileName: String? = nil
    public var separator: String = "\t"
    public var skipCharacters: [String] = ["#", "@"]

    // Abstract function, must be overwritten by real classes.
    public func convertToObject(_ records: [String]) throws -> T? {
        assertionFailure("BIOSWIFT ERROR: this method should not be called directly!")
        return nil
    }
    
    init() {
        
    }

    private func lineToArray(_ line: String) -> [String]? {

        // FIXME: Use exception if the computed array is malformed 
        // instead trying to figure out all the possible separators.
        // let separators = NSCharacterSet(charactersInString: "\t ")
        // let array = line.componentsSeparatedByCharactersInSet(separators)

        let array = line.components(separatedBy: self.separator).filter {
            (element) -> Bool in
            !element.isEmpty
        }

        // Check whether it's a skip line such as # or @ as the first car
        // It does not mean the line cannot be malformed use exception when
        // when converting array to object.
        let firstChar = array[0].characters.first!
        let skipLine = skipCharacters.contains(String(firstChar))


        if array.isEmpty || skipLine {
            return nil
        } else {
            return array
        }

    }

    public func parse(_ fileName: String? = nil) {
        guard let _ = fileName, let contents = try? String(contentsOfFile: fileName!,  encoding: String.Encoding.ascii) else { return }

        self.fileName = fileName

        for line in contents.components(separatedBy: "\n") {
            // Skip the empty lines.
            if !line.isEmpty {
                if let array = lineToArray(line) {

                    do {
                        if let offtarget = try convertToObject(array) {
                            results.append(offtarget)
                        }
                    } catch let error {
                        debugPrint("BIOSWIFT ERROR: \(error)")
                    }
                }
            }
        }
    }
}
