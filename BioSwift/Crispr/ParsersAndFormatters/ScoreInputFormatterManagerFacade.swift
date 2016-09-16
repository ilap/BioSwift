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
/// Difference between parser and formatter
/// Parser: From file to memory.
/// Formatter: Memory to File.
///
public class ScoreInputFormatterManagerFacade {
    let factory: RNATargetFactory<VisitorProtocol?>
    
    private var visitableOntargets: [VisitableProtocol?]
    
    init(onTargets: [VisitableProtocol?]) {
        self.visitableOntargets = onTargets
        self.factory = RNATargetFactory<VisitorProtocol?>()
    }
    
    func getFormatter(formatter: RNATargetParserType, path: String?) -> VisitorProtocol {
        return try! factory.getFormatter(formatter, path: path)!
    }
    
    func accept(visitor: VisitorProtocol) {
        for part in visitableOntargets {
            part?.accept(visitor: visitor)
        }
    }
}
