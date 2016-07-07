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

public protocol TargetProtocol {
    //var loci: Int { get set }
    //var endLoci: Int { get set }
    
    var sequence: String { get set }
    var pam: String { get set }
    var name: String { get set }
    var strand: String { get set }
    var position: Int { get set }
    var length: Int { get set }
    
    var score: Float { get set }
}

protocol ScoreFunctionProtocol {
    //    associatedtype T
    var parser: ParserProtocol { get set }
    var formatter: VisitorProtocol { get set }
    //    func score(genome: SeqRecord, guideRNAs: [String], maskedPam: String,) -> [T]?
}

protocol ScoreCommandParameterProtocol {
    
    var command: String { get set }
    var args: [String] { get set }
    
    var sourceFile: String { get set }
    var inputFile: String  { get set }
    var outputFile: String  { get set }
    
    func parseCommand() -> String
}


class AbstractCommandParameters: ScoreCommandParameterProtocol {

    let bundlePath: String

    var command: String = ""
    var args: [String] = []
    
    var sourceFile: String
    var inputFile: String
    var outputFile: String
    
    init(sourceFile: String, inputFile: String, outputFile: String) {
        self.sourceFile = sourceFile
        self.inputFile = inputFile
        self.outputFile = outputFile
        
        

#if !os(Linux)
    bundlePath = Bundle(for: AbstractCommandParameters.self).resourcePath! + "/Resources/ScoreCommands/"
#else
    bundlePath = "./ScoreCommands"
#endif
        
        
        self.initialise()
    }
    
    func initialise() {
        
        // override
    }
    
    func parseCommand() -> String {
        return "AAAA"
        
    }
    
}


class CasOffinderCommandParameters: AbstractCommandParameters {
    private var computeMethod: String = "C" // "G" for CPU or "A" for accelerators
    
    override func initialise() {
        #if !os(Linux)
            command = "\(bundlePath)/cas-offinder_singlefile_macos"
        #else
            command = "\(bundlePath)/cas-offinder_singlefile_linux_64"
        #endif
        
        
        args = [inputFile, computeMethod, outputFile]
        
        print("SCOREFUNC: \(command) ... \(args)")
    }
}

///
/// Parameters:
/// = Generated Ontargets
/// = Source/Genome sequence File
/// = ScoreParameters: max mismatch, seed mismatch. etc.
/// Result: scored Offtargets.

class CasOffinderScoreFunction: ScoreFunctionProtocol, TaskProtocol  {
    var parser: ParserProtocol
    var formatter: VisitorProtocol
    
    var ontargets: [VisitableProtocol?]
    var results: [OfftargetProtocol] = []
    
    var sequenceFile: String
    
    let spacerLength = 20
    let maskedPAM = "NGG"
    let scoreInputFile = "/tmp/INPUT"
    let scoreOutputFile = "/tmp/OUTPUT.cof"
    
    
    private (set) var isDone : Int32 = 0
    
    var name: String = "CasOffinder Score Task"
    var progress: Int = 0
    var messages: [String] = []
    
    var successCommand: Command? = nil
    var failCommand: Command? = nil
    var progressCommand: Command? = nil
    
    init(source: DesignSourceProtocol?, target: DesignTargetProtocol?, ontargets: [VisitableProtocol?], parameters: DesignParameterProtocol?) {
    
    //init(sequenceFile: String, ontargets: [VisitableProtocol?], targetStart: Int?, targetEnd: Int?) {
        
        self.sequenceFile = source!.path //sequenceFile
        self.ontargets = ontargets
        
        //let start = target!.location
        //let end = start + target!.length
        
        //self.parser = CasOffinderOutputParser(targetStart: start, targetEnd: end)
        
        self.parser = CasOffinderOutputParser(designTarget: target, designParameters: parameters) //Start: start, targetEnd: end)
        
        

        self.formatter = CasOffinderInputFormatter(path: scoreInputFile)!
        
        //self.parameters = CasOffinderCommandParameters(sourceFile: sourceFile, inputFile: inputFile, outputFile: outputFile)
    }
    
    
    
    func run() {
        
        print("\(name) is Running formatter file: \((formatter as! CasOffinderInputFormatter).fileName)")
        
        let initial = CasOffinderInitialSequence(genome: sequenceFile, spacerLength: spacerLength, maskedPAM: maskedPAM)
        
        var ot = [initial as VisitableProtocol?]
        
        ot += ontargets //ontargets.insert(initial, at: 0)
        
        let facade = ScoreInputFormatterManagerFacade(onTargets: ot)
        
        facade.accept(visitor: formatter)
        
        let parameters =  CasOffinderCommandParameters(sourceFile: sequenceFile, inputFile: scoreInputFile,
                                                       outputFile: scoreOutputFile)
        
        let sf = ScoreFunctionTask(parameters: parameters)
        
        sf.run()
        
        var stdout: [String] = []
        var stderr: [String] = []
        var err: Int32 = 0
        (stdout, stderr, err) = sf.runCommand()
        
        if err == 0 {
            print("Aggregating Ontargets")
            if aggregateOnTargets() {
                successCommand?.execute(self)
            }
            print("HEUREKA")
            print("ERROR")
            print(stderr)
            print("OUTPUT)")
            print(stdout)
        } else {
            print("Scoring Ontargets has failed...")
            failCommand?.execute(self)
            print("ERROR")
            print(stderr)
            print("OUTPUT)")
            print(stdout)
            return
        }
        
    }
    
    private func aggregateOnTargets() -> Bool {
        let parserFacade = OffTargetParserManagerFacade<OfftargetProtocol>()
        
        do {
            if let results = try parserFacade.parseFile(parser: parser, scoreOutputFile) {
                self.results = results
                
                for result in self.results {
                    
                    print("ITEM: \(result.guideRNA!), \(result.querySequence) \(result.homology)")
                }
            } else {
                print("NO ANY RESULT")
            }
        } catch let error {
            print ("BIOSWIFT ERROR:: \(error)")
        }
        
        return true
    }
    
}


