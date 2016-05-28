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


class ScoreFunctionManager {

    var scoreFunctions: [ScoreFunctionType:ScoreTask] = [:]
    var _defaultScoreFunction: ScoreFunctionType = .CasOffinder

    var scoreFunction: ScoreFunctionType {
        get {
            return  _defaultScoreFunction
        }
        set {
            if let _ = scoreFunctions[newValue] {
                _defaultScoreFunction = newValue
            }
        }
    }
    init() {
        initialise()
    }

    public func getScoreFunction() -> ScoreTask {
        return scoreFunctions[_defaultScoreFunction]!
    }

    private func initialise() {
        // Use Abstract factory helper to initialise all factories
        for function in ScoreFunctionType.allValues {
            ////if let functionProvider = ScoreFunctionProvider.factory(function) {
            ///    scoreFunctions[function] = functionProvider
            ///}
        }
    }


}
