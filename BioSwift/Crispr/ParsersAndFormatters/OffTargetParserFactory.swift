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
protocol GenericFactory {
    associatedtype T
    func getParser(_ parser: RNATargetParserType) throws -> T
    func getFormatter(_ formatter: RNATargetParserType, path: String?) throws -> T
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
public class RNATargetFactory<T>:  GenericFactory {

    var parsers: [RNATargetParserType:ParserProtocol] = [:]
    var formatters: [RNATargetParserType:VisitorProtocol] = [:]
    
    init() {
        initialise()
    }

    func getFormatter(_ formatter: RNATargetParserType, path: String?) throws -> T {
        
        
        if let result = formatters[formatter] {
            return result as! T
        } else {
            formatters[formatter] = ScoreInputFormatterProvider.factory(formatter, path: path)
            if let result = formatters[formatter] {
                return result as! T
            } else {
                throw BioSwiftError.parserError("BIOSWIFT ERROR: no parser  \"\(formatter)\" in parsers (\(formatters))!")
            }
        }
    }
    
    func getParser(_ parser: RNATargetParserType) throws -> T {


        if let result = parsers[parser] {
            return result as! T
        } else {
            throw BioSwiftError.parserError("BIOSWIFT ERROR: no parser  \"\(parser)\" in parsers (\(parsers))!")
        }
    }
    
    private func initialise() {
        // Use Abstract factory helper to initialise all factories
        for parserType in RNATargetParserType.allValues {
            parsers[parserType] = ScoreOutputParserProvider.factory(parserType)
        }
    }
}
