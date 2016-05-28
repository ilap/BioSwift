//
//  BioSwiftTaskTests.swift
//  BioSwift
//
//  Created by Pal Dorogi on 26/05/2016.
//  Copyright © 2016 Pal Dorogi. All rights reserved.
//

import XCTest

@testable import BioSwift

class BioSwiftTaskTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testTaskPattern() {

        let taskMediator = TaskMediator(task: LongTaskForUnitTest())

        taskMediator.initWorkerAndRunTask()
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }

}
