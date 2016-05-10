//
//  BioSwiftTests.swift
//  BioSwiftTests
//
//  Created by Pal Dorogi on 16/04/2016.
//  Copyright © 2016 Pal Dorogi. All rights reserved.
//

import XCTest
@testable import BioSwift

class BioSwiftTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testOnTargetsInSequence() {
                              // 0123456789012345678901
        var seq = Seq(sequence: "ACGTACGTACGGGCTGAGACGT")
        var pam = ["NGG", "NAG"]
        
        if let res = seq.getOnTargets(pam, start: 0, end: Int(seq.length)) {
            assert (res == [9, 10, 15])
        }
        
                          // 012345678901234567
        seq = Seq(sequence: "ATTCCAGAGCAATCCCGT")
        pams = ["NTTNNA", "ANNAAT", "GCNNTC"]
        
        if let res = seq.getOnTargets(pams, start: 0, end: Int(seq.length)) {
            assert (res == [0, 7, 8])
        }
    
        
                          // 0123456789012345678901
        seq = Seq(sequence: "ACGTACGTACATACTGATACGT")
        let res = seq.getOnTargets(pam, start: 0, end: Int(seq.length))
        assert(res == nil)
    }
    
    func testSequenceSubscript() {
        let seq = Seq(sequence: "ACGTACGTACGGGCTGAGACGT")
        
        assert( seq[0] == "A")
        assert( seq[1] == Character("C"))
        assert( seq[0...2] == "ACG")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
