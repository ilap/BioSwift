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
import XCTest

@testable import BioSwift


// TestTast classes
class LongTaskForUnitTest: TaskProtocol {
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
        print("It's running \(name)")
        let to=40000000.0
        let mod=400000
        var sum = 0.0
        var p = 0
        for i in 0...Int(to) {
            if i % mod == 0 {
                p = Int(100*Float(i) / Float(to))
                self.progress = p
                self.progressCommand?.execute(self)
            }
            sum += 10 * 2
        }
        self.successCommand?.execute(self)
    }
}

public class BioSwiftTaskTests: XCTestCase {

#if os(Linux)
    public var allTests: [(String, () throws -> Void)] {
    return [
    ("testTaskPattern", testTaskPattern),
    ("testBowtieScoreFunction", testBowtieScoreFunction),
    ]
    }
#else
    
    

    override public func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override public func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
#endif

    func testTaskPattern() {
        //let taskMediator = TaskMediator(tasks: [LongTaskForUnitTest(name: "Task A"), LongTaskForUnitTest(name: "Task B")])
        // Async operation...
        //taskMediator.initWorkerAndRunTask()
        // Not Async... taskMediator.runTasks()
    }
    
    
    func testFormatter() {
        // Generate Ontargets
        // Create temp file
        //
        // Use visitor pattern for format OnTargets to the desired input file
        // of the formatter e.g. BWA, Bowtie, Bowtie2 etc..
    }

    func testOffTarget() {
        // Create Design Source Objects
        // Create Design Target Objects
        // Select/Create Nuclease Object
        // Create DesignParameters based on CLI parameters and Nuclease settings 
        // e.g. OntargetPAMs = NucleasePAMs, OfftargetPAMs = subset of OntargetPAMs
        // Seedlength and spacer Length
        
        
    }
    
}
