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
/// Implements the Worker Thread pattern similar to SwingWorker in Java.
/// Doug Lea. 1999. Concurrent Programming in Java: Design Principles and Patterns.
///
protocol WorkerThreadProtocol: Command {
    func runInBackground()
}

public class AsyncWorkerThread: WorkerThreadProtocol {
    private var runAsync: Bool = true

    init() {    }


    public func execute(_ receiver: Any) {
        // FIXME: Make it work for Linux
#if os(Linux)
            self.runInBackground()
#else
        if runAsync {
            if #available(OSX 10.10, *) {
                DispatchQueue.global(attributes: .qosDefault).async(execute: {
                    print("Async task's invoked...")
                    self.runInBackground()
                })
            } else {
                assertionFailure("FATAL ERROR: It requires OSX 10.10")
            };
        } else {
            self.runInBackground()
        }
#endif
    }

    func runInBackground() {
        assertionFailure("FATAL ERROR: This function should not be reached!")
    }
}


public class TaskWorker: AsyncWorkerThread {

    public var task: TaskProtocol

    public init(task: TaskProtocol, runAsync: Bool = true) {
        self.task = task
        super.init()
        self.runAsync = runAsync
    }

    override func runInBackground() {
        task.run()
    }
}
