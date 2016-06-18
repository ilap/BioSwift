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
/// Implements an Async Worker Thread pattern similar to SwingWorker in Java.
///
/// T - the result type returned by backgroundTask
/// V - the type used for carrying out intermediate results by publish and process methods
public class SandboxAsyncWorkerTask<T,V> {

    public typealias preClosure = (() -> ())
    public typealias backgroundClosure = (param: T) -> V
    public typealias postClosure = ((param: V) -> ())

    // Called prior to backgroundClosure
    private var preTask: preClosure?
    private var backgroundTask: backgroundClosure?
    private var postTask: postClosure?

    init(backgroundTask: backgroundClosure? = nil, preTask: preClosure? = nil, postTask: postClosure? = nil) {

        self.preTask = preTask
        self.backgroundTask = backgroundTask
        self.postTask = postTask

    }

    public func execute(_ param: T) {
        print("EXECUTE")
        guard let _ = self.backgroundTask else {
            // TODO: Throw error
            print("ASYNC OOOPS")

            assertionFailure("FATAL ERROR: background task has not been initialised properly.")
            return
        }

        preTask?()

        #if os(OSX)
        if #available(OSX 10.10, *) {
            DispatchQueue.global(attributes: .qosDefault).async(execute: {
                print("ASYNC STARTED")
                let result = self.backgroundTask!(param: param)

                if let _ = self.postTask {
                    DispatchQueue.main.async(execute: {
                        self.postTask?(param: result)
                    })
                }
            })

        } else {
            assertionFailure("FATAL ERROR: It requires OSX 10.10")
        };
        #elseif os(Linux)
            let result = self.backgroundTask!(param: param)

            if let _ = self.postTask {
                self.postTask?(param: result)
            }
        #endif
    }
}

public class SandboxTaskWorker: SandboxAsyncWorkerTask<String, Int> {

    var task: TaskProtocol

    init(task: TaskProtocol) {
        self.task = task
        super.init()

    }

    func construct() {
        backgroundTask = self.longRunFunc
    }

    func start() {
        construct()
        self.execute("Nothing")
    }

    func longRunFunc(_ param: String) -> Int {
        print("TASK IS RUNNUNG")
        task.run()
        return 0
    }
}
