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


public class BioSwiftParserTests: XCTestCase {

#if os(Linux)
    public var allTests: [(String, () throws -> Void)] {
    return [
    ("testParsingCasOffinderOutput", testParsingCasOffinderOutput),
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

    func testParsingCasOffinderOutput() {
    /// #1. Generate Score inputfile
    #if !os(Linux)
        let testBundle = Bundle(for: BioSwiftParserTests.self)
        let fileName = testBundle.pathForResource("./Resources/Genomes/sequence1", ofType: "fa")
        //let fileName = testBundle.pathForResource( "/Users/ilap/Developer/Dissertation//BioSwift/BioSwiftTests/Resources/Genomes/sequence2", ofType: "fa")

    #else
        let fileName = "./Resources/Genomes/sequence1.fa"
        #endif
        
        // FileParserFacade facade = new FileParserFacade();
        let facade = OffTargetParserManagerFacade<TargetProtocol>()

        do {
            if let results = try facade.parseFile(fileName) {
                for result in results {

                    print("ITEM: \(result.sequence), \(result.querySequence) \(result.score)")
                }
            } else {
                print("NO ANY RESULT")
            }
        } catch let error {
            print ("BIOSWIFT ERROR:: \(error)")
        }

    }

    
/*    ///
    /// The inputs are the Ontarget objects extended by the visitor pattern.
    ///
    func testCasOffinderInputFormatter() {
        /// #1. Generate Score inputfile
#if !os(Linux)
        let testBundle = Bundle(for: BioSwiftParserTests.self)
        let fileName = testBundle.pathForResource("./Resources/Genomes/sequence1", ofType: "fa")
#else
        let fileName = "./Resources/Genomes/sequence1.fa"
#endif
        // let allPAMs = ["NGG", "NAG", "NGA", "NAA"]
        let allPAMs = MockPAM.getPAMs().map {
            ($0?.sequence)!
        }

        let usedPAMs = ["NGG"]
        let seedLength = 10
        let spacerLengt = 20
        
        let record = try? SeqIO.parse(fileName)?[0]!
        
        let cu = CrisprUtil(record: record!!, allPAMs: allPAMs)
        cu.spacerLength = spacerLengt
        cu.seedLength = seedLength
        
        let start = 25
        let end = 125
        let ontargets = cu.getOnTargets(usedPAMs, start: start, end: end)

        let scoreTask = CasOffinderScoreFunction(sequenceFile: fileName!, ontargets: ontargets!, targetStart: start, targetEnd: end)
        let scoreTaskMediator = TaskMediator(task: scoreTask)
        
        scoreTaskMediator.runTasks()
        
        print("RESULT \(scoreTask.results)")
    }

*/
    ///
    /// The inputs are the Ontarget objects extended by the visitor pattern.
    ///
    func testCasOffinderScoreFunctionOnMockData() {
        /// #1. Generate Score inputfile
        #if !os(Linux)
            let testBundle = Bundle(for: BioSwiftParserTests.self)
            //let fileName = testBundle.pathForResource("./Resources/Genomes/sequence1", ofType: "fa")
            let fileName =  "/Users/ilap/Developer/Dissertation//BioSwift/BioSwiftTests/Resources/Genomes/sequence2.fa"

        #else
            let fileName = "./Resources/Genomes/sequence1.fa"
        #endif
        
        let designSources = MockDesignSource.getDesignSources(path: fileName)
        
        print(designSources.map {
            $0?.path
            })
        
        let allPAMs = MockPAM.getPAMs()
        
        let usedPAMs = allPAMs.filter {
            $0?.sequence == "NGG"
        }
        
        let designTargets = MockDesignTarget.getDesignTargets()
        
        let parameters = DesignParameters()
        
        let ds = MockDesignSourceAdapter(designSource: designSources[0]!, designTargets: designTargets, designParameters: parameters)
        
        let ontargets = ds.getOntargets(pams: usedPAMs)
        
        let scoreTask = CasOffinderScoreFunction(sequenceFile: (designSources.first!?.path)!, target: designTargets.first!, ontargets: ontargets!, pams: allPAMs, parameters: parameters)
        
        let scoreTaskMediator = TaskMediator(task: scoreTask, isThreadable: false)
        
        scoreTaskMediator.runTasks()
        
        for guide in scoreTask.ontargets {
            let i = guide as! RNAOnTarget
            var s = i.sequence
            var ss = "*"
            var c = i.complement
            var cc = " "
            
            if i.strand == "-" {
                s = i.complement
                c = i.sequence
                ss = " "
                cc = "*"
            }
            print("")
            print("+:\t\t\(ss)\(s!)")
            let prec = String(format: "%.5f%", i.score!)
            print("\(prec):\(i.location!)\t\t ||||||||||||||||||||\t\(i.speciesName!)")
            print("-:\t\t\(cc)\(c!)")
            print("")
        }
    }
}

class MockDesignSourceAdapter {
    
    var designSource: DesignSourceProtocol?
    var designParameters: DesignParameterProtocol
    
    var pams: PAMProtocol?
    
    var designTargets: [DesignTargetProtocol?] {

        didSet {
            // TODO: 
           initialise()
        }
    }
    
    private var crisprUtil: CrisprUtil? = nil
    
    init(designSource: DesignSourceProtocol?, designTargets: [DesignTargetProtocol?], designParameters: DesignParameterProtocol) {
        
        self.designSource = designSource
        self.designParameters = designParameters
        self.designTargets = designTargets

        initialise()

    }
    
    private func initialise() {
        let record = (designSource as! DesignSourceModelProtocol?)?.seqRecord
        self.crisprUtil = CrisprUtil(record: record!, parameters: designParameters)
    }
    
    func getOntargets(pams: [PAMProtocol?]) -> [VisitableProtocol?]? {
        var result: [VisitableProtocol?] = []
        //XXXXXX: print ("XXXXXX: "  + #function + ": pams \(pams) \n \(pams.map { $0?.sequence})\n:")

        for target in designTargets {
            let start = (target?.location)! - (target?.offset)!
            let end = start + (target?.length)! + 2 * (target?.offset)!
            print (#function + ": pams \(pams) \n \(pams.map { $0?.sequence})\n: start \(start) end \(end)")
            
            let r = self.crisprUtil?.getPAMOnTargets(pams, start: start, end: end)

            result += r!
        }
        
        return result
    }
}



