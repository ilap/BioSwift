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

///
/// GoF's Strategy pattern for parsing the outputs of the ran Score fucntion
/// apps such as BWA, Bowtie, Bowtie2 and Cas-Offinder
///

/// Protocol for the interface
protocol TaskParserProtocol {
    func parse(data: String)
}

///
/// Stragegy for each scoring function
///

/// Parse for CasOffinder
class SAMParser: TaskParserProtocol {
    func parse(data: String) {
        return
    }
}



///
/// Caller/Client class using decorator pattern to decorate parsing strategy
///
class TaskParserManager {
    private let parser: TaskParserProtocol

    init(parser: TaskParserProtocol) {
        self.parser = parser
    }

    func applyParse() {
        parser.parse("DATA")
    }


}