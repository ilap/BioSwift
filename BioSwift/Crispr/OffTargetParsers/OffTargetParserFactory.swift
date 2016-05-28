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

/// FIXME: Change it to generic e.g. get rid of OffTargetParserType
protocol GenericParserFactory {
    associatedtype T
    func getParser(parser: OffTargetParserType) throws -> T
}


///
/// GoF's Abstractfactory pattern for the existing scorefunctions.
///
/// Simple UML explanation:
/// http://usna86-techbits.blogspot.co.uk/2012/11/uml-class-diagram-relationships.html
///
/// FIXME: Change it to a generic parser factory and get rid of all the 
/// dependenies.
///
public class OffTargetParserFactory<T>:  GenericParserFactory {

    var parsers: [OffTargetParserType:ParserProtocol] = [:]

    init() {
        initialise()
    }

    func getParser(parser: OffTargetParserType) throws -> T {


        if let result = parsers[parser] {
            return result as! T
        } else {
            throw BioSwiftError.ParserError("BIOSWIFT ERROR: no parser  \"\(parser)\" in parsers (\(parsers))!")
        }
    }

    private func initialise() {
        // Use Abstract factory helper to initialise all factories
        for parserType in OffTargetParserType.allValues {
            parsers[parserType] = OffTargetParserProvider.factory(parserType)
        }
    }
}