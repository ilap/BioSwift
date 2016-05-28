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
public class OffTargetParserManagerFacade<T> {
    let factory: OffTargetParserFactory<ParserProtocol?>
    var parser: GenericParser<T>? = nil

    init() {
        self.factory = OffTargetParserFactory<ParserProtocol?>()
    }

    public func parseFile(fileName: String?) throws {
        // Validate first then get the type of the file
        // currently by extension as the result file is handled internally so
        // no any external app will touch it.
        // 
        if let _ = fileName, let type = self.getParserType(fileName!) {
            self.parser = try factory.getParser(type) as! GenericParser<T>?
            parser!.parse(fileName!)

            print("HEUREKA \(self.parser)")
        }
    }

    func getParserType(fileName: String) -> OffTargetParserType? {

        let ext = (fileName as NSString).pathExtension

        if let type = OffTargetParserType.getTypeFromExtension(ext) {
            return type
        } else {
            return nil
        }
    }

}