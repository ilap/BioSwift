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

    var tasks: [TaskProtocol] = []

    init(task: TaskProtocol) {
        self.tasks.append(task)
        initialise()
    }

    init(tasks: [TaskProtocol]) {
        self.tasks = tasks
        initialise()
    }

    private func initialise() {
        for var task in tasks {
            print("Initialise task: \(task.name)")
            task.successCommand = RelayCommand(action: success/*, canExecute: canExecute*/)
            task.failCommand = RelayCommand(action: fail/*, canExecute: canExecute*/)
            task.progressCommand = RelayCommand(action: progress/*, canExecute: canExecute*/)
        }
    }

    ///
    /// Not using Threads
    ///
    func runTasks() {
        for task in tasks {
            task.run()
        }
    }

    /// Using Threads
    func initWorkerAndRunTask() {
        for task in tasks {
            print("TASK: \(task.name)")
            let worker = TaskWorker(task: task)
            worker.execute(task)
        }
    }

    func success(_ receiver: Any) {
        print("Success ")
    }

    func fail(_ receiver: Any) {
        print("Fail")
    }

    func progress(_ receiver: Any) {
        
        guard let currentTask = receiver as? TaskProtocol else {
            fatalError("Receiver is not a TaskProtocol")
        }
        
        print("Progress \(currentTask.progress), \(currentTask.name)")

    }
}
