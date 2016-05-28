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
/// Implements Mediator design for Task
///
class TaskMediator {

    var task: TaskProtocol

    init(task: TaskProtocol) {
        self.task = task
        initialise()
    }

    private func initialise() {
        self.task.successCommand = RelayCommand(action: success/*, canExecute: canExecute*/)
        self.task.failCommand = RelayCommand(action: fail/*, canExecute: canExecute*/)
        self.task.progressCommand = RelayCommand(action: progress/*, canExecute: canExecute*/)
    }

    ///
    /// Not using Threads
    ///
    func runTask() {
        task.run()
    }

    /// Using Threads
    func initWorkerAndRunTask() {
        let worker = TaskWorker(task: self.task)
        worker.execute()
    }

    func success() {
        print("Success ")
    }

    func fail() {
        print("Fail")
    }

    func progress() {
        print("Progress \(task.progress)")
    }
}