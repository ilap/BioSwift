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
private let queue = DispatchQueue(label: "task-worker", attributes: DispatchQueueAttributes.serial)
#endif

infix operator ~> {}

func ~> <T> ( background: () -> T, main: (result: T) -> ()) {
    #if os(OSX)
    queue.async {
        let result = background()
        DispatchQueue.main.async(execute: {main(result: result)})
    }
    #else
        assertionFailure("It's not implemented yet.")
    #endif
}


protocol TaskProtocol {
    var name: String { get }
    var progress: Int { get set }
    var messages: [String] { get set }

    var successCommand: Command? { get set }
    var failCommand: Command? { get set }
    var progressCommand: Command? { get set }

    func run()
}


