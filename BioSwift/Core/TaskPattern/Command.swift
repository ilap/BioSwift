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
/// Command Design Pattern implelmented in Swift
///
protocol Command2 {
    // TODO: Enhance the pattern.
    associatedtype T
    func execute(_ receiver: T) -> Void
    //func undo() -> Void
}

typealias CommandClosure2 = (receiver: Any) -> Void
///
/// TODO: Implements this
/// http://audreyli.me/2015/07/03/a-design-pattern-story-in-swift-chapter-6-command/
///
class RelayCommand2<T>: Command2 {
    var action: CommandClosure2
    var canExecute: Bool
    
    init(action: CommandClosure2, canExecute: Bool = true) {
        self.action = action
        self.canExecute = canExecute
    }
    
    func execute(_ receiver: T) {
        if canExecute {
            self.action(receiver: receiver)
        }
        
    }
}


///
/// Command Design Pattern implelmented in Swift
///
public protocol Command {
    func execute(_ receiver: Any) -> Void
}


typealias CommandClosure = (receiver: Any) -> Void

class RelayCommand: Command {
    var action: CommandClosure
    var canExecute: Bool

    init(action: CommandClosure, canExecute: Bool = true) {
        self.action = action
        self.canExecute = canExecute
    }

    func execute(_ receiver: Any) {
        if canExecute {
            self.action(receiver: receiver)
        }

    }
}
