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
/// Implements Task Pattern using Command, Command Holder and Mediator design
/// patterns
///

#if os(OSX)
private let queue = dispatch_queue_create("task-worker", DISPATCH_QUEUE_SERIAL)
#endif

infix operator ~> {}

func ~> <T> ( background: () -> T, main: (result: T) -> ()) {
    #if os(OSX)
    dispatch_async(queue) {
        let result = background()
        dispatch_async(dispatch_get_main_queue(), {main(result: result)})
    }
    #else
        assertionFailure("It's not implemented yet.")
    #endif
}


protocol TaskProtocol {
    var progress: Int { get set }
    var messages: [String] { get set }

    var successCommand: Command? { get set }
    var failCommand: Command? { get set }
    var progressCommand: Command? { get set }

    func run()
}

// TestTast classes
class LongTaskForUnitTest: TaskProtocol {

    var progress: Int = 0
    var messages: [String] = []

    var successCommand: Command? = nil
    var failCommand: Command? = nil
    var progressCommand: Command? = nil

    func run() {
        let to=40000000.0
        let mod=400000
        var sum = 0.0
        var p = 0
        for i in 0...Int(to) {
            if i % mod == 0 {
                p = Int(100*Float(i) / Float(to))
                self.progress = p
                self.progressCommand?.execute()
            }
            sum += 10 * 2
        }
        self.successCommand?.execute()
    }
}


