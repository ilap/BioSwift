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

class ScoreFucntionTask2: TaskProtocol {
    var name: String
    var progress: Int = 0
    var messages: [String] = []
    
    var successCommand: Command? = nil
    var failCommand: Command? = nil
    var progressCommand: Command? = nil
    
    init(name: String) {
        self.name = name
    }
    
    func run() {

    }
}


class ScoreFunctionManagerFacade {
    var sources: [SeqRecord:[TargetProtocol]] = [:]
    var tasks: [TaskProtocol] = []
    
    var scoreFunction: ScoreFunctionProtocol? = nil

    init(scoreFunction: ScoreFunctionProtocol, sources: [SeqRecord:[TargetProtocol]], allPAMs: [String], usedPAMs: [String], seedLength: Int, spacerLength: Int) {
        self.scoreFunction = scoreFunction
        self.sources = sources
        
        self.initialise()
    }
    
    private func initialise() {
        for (_, _) in sources {
            //tasks.append(ScoreTaskWorker())
            // let worker = ScoreFunctionWorker(task: task, scoreFunction: scoreFunction)
            // worker.execute(task)
            
        }
        
        
        for var task in tasks {
            task.successCommand = RelayCommand(action: success/*, canExecute: canExecute*/)
            task.failCommand = RelayCommand(action: fail/*, canExecute: canExecute*/)
            task.progressCommand = RelayCommand(action: progress/*, canExecute: canExecute*/)
        }
    }
    
    
    
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

    func score() {
        for source in sources {
            print(source)
            // Step 1. Set the parameters (source(s), target(s), extra parameters
            // Step 2. Collect all of the on-targets.
            // Step 3. write gRNAs to the proper outpout format (based on Score Function)
            // Step 4. Run function on the genome and on the guide RNAs
            // Step 5. 
            //
            //scoreFunction.score(genome, guideRNAs)
        }
    }
}

