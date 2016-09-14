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

    var sequence: String? { get set }
    var complement: String? { get set }
    var pam: String? { get set }
    var speciesName: String? { get set }
    var strand: String? { get set }
    var location: Int? { get set }
    var length: Int? { get set }
    var score: Double? { get set }

    // Store the query sequence on which the sequence is compared
    // e.g. score based on this comparison
    var querySequence: String? { get set }

}

public protocol ScoreFunctionProtocol {
    //    associatedtype T
    var parser: ParserProtocol { get set }
    var formatter: VisitorProtocol { get set }
    //    func score(genome: SeqRecord, guideRNAs: [String], maskedPam: String,) -> [T]?
}

public protocol ScoreCommandParameterProtocol {
    
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
    if let _ = NSClassFromString("XCTest") {
        self.bundlePath = Bundle(for: AbstractCommandParameters.self).resourcePath! + "/Resources/ScoreCommands/"
    } else {
        self.bundlePath = Bundle(for: AbstractCommandParameters.self).resourcePath! + "/ScoreCommands/"
    }
    //XXX: ilap print("\n\nPAAAAAAAAAATH \(bundlePath)\n\n\n")
    
#else
        self.bundlePath = "./ScoreCommands"
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
        
        //DEBUG print("SCOREFUNC: \(command) ... \(args)")
    }
}

///
/// Parameters:
/// = Generated Ontargets
/// = Source/Genome sequence File
/// = ScoreParameters: max mismatch, seed mismatch. etc.
/// Result: scored Offtargets.
public class CasOffinderScoreFunction: ScoreFunctionProtocol, TaskProtocol  {
    public var parser: ParserProtocol
    public var formatter: VisitorProtocol
    
    public var ontargets: [VisitableProtocol?]
    public var results: [TargetProtocol] = []
    
    var sequenceFile: String
    
    var spacerLength = 0 //20
    var maskedPAM = ""
    var scoreInputFile = ""
    var scoreOutputFile = ""
    
    var sequenceDir = ""
    
    let pams: [PAMProtocol?]
    
    
    private (set) var isDone : Int32 = 0
    
    public var name: String = "CasOffinder Score Task"
    public var progress: Int = 0
    public var messages: [String] = []
    
    public var successCommand: Command? = nil
    public var failCommand: Command? = nil
    public var progressCommand: Command? = nil
    
    public init(sequenceFile: String /*, source: DesignSourceProtocol?*/, target: DesignTargetProtocol?, ontargets: [VisitableProtocol?], pams: [PAMProtocol?], parameters: DesignParameterProtocol?) {
    

        self.sequenceFile = sequenceFile
        self.scoreInputFile = BioSwiftFileUtil.generateTempFileName()!
        self.scoreOutputFile = BioSwiftFileUtil.generateTempFileName()!
        
        self.scoreInputFile = "/tmp/INPUT"
        self.scoreOutputFile = "/tmp/OUTPUT.cof"
        
        self.pams = pams
        maskedPAM = CrisprUtil.computeMaskedPAM(pams: self.pams)
        spacerLength = (parameters?.spacerLength)!

        self.ontargets = ontargets
        
        parser = CasOffinderOutputParser(designTarget: target, designParameters: parameters)
        formatter = CasOffinderInputFormatter(path: scoreInputFile)!
    }
    
     
    public func run() {
        
        // DEBUG: print("\(name) is Running formatter file: \((formatter as! CasOffinderInputFormatter).fileName)")
        
        let initial = CasOffinderInitialSequence(genome: sequenceFile, spacerLength: spacerLength, maskedPAM: maskedPAM)
        
        var ot = [initial as VisitableProtocol?]
        
        ot += ontargets //ontargets.insert(initial, at: 0)
        
        let facade = ScoreInputFormatterManagerFacade(onTargets: ot)
        
        facade.accept(visitor: formatter)
        
        let parameters =  CasOffinderCommandParameters(sourceFile: sequenceFile, inputFile: scoreInputFile,
                                                       outputFile: scoreOutputFile)
        
        let sf = ScoreFunctionTask(parameters: parameters)
        
        //sf.progressCommand =
        //sf.run()
        
        var stdout: [String] = []
        var stderr: [String] = []
        var err: Int32 = 0
        //DEBUG: sf.debugPrint()
        (stdout, stderr, err) = sf.runCommand()
        
        if err == 0 {
            print("Aggregating Ontargets...")
            if aggregateOnTargets() {
                successCommand?.execute(self)
            } else {
                failCommand?.execute(self)
            }
        } else {
            failCommand?.execute(self)
        }
        
         // Clean the output file.
        let fileManager = FileManager.default
        do {
           // try fileManager.removeItem(atPath: scoreInputFile)
           // try fileManager.removeItem(atPath: scoreOutputFile)
        } catch let error as NSError {
            print("Cannot delete score output file: \(error)")
        }

    }
    
    private func aggregateOnTargets() -> Bool {
        let parserFacade = OffTargetParserManagerFacade<TargetProtocol>()
        
        do {
            if let results = try parserFacade.parseFile(parser: parser, scoreOutputFile) {
                self.results = results
                
                let res_len = results.count
                
                var idx = 0

                
                var off_affinity = 0.0
                var off_pam = ""
                var off_score = 0.0
                var off_seq = ""
                
                var on_seq = ""
                
                for (xx, offtarget) in self.results.enumerated() {
                    
                    on_seq = (ontargets[idx]?.text)!
                    
                    // FIXME: it is assumed that the ontargets are ordered
                    // It won't work if the output is not ordered.
                    var ontarget = ontargets[idx] as! TargetProtocol
                    
                    if off_pam != offtarget.pam {
                        off_pam = offtarget.pam!
                        
                        if let pam = CrisprUtil.getCompatibleCanonicalPAM(pams: pams, realPAM: offtarget.pam!) {
                            off_affinity = Double(pam.survival)
                        } else {
                            
                            off_affinity = ontarget.score!
                            // FIXME: If wrong PAM is found then use largest affinity.
                            //assertionFailure("\n\nUnconform canonical PAM has detected at location \(offtarget.location)!\n" +
                             //   "Only \"N\", \"R\", \"A\", \"G\", \"C\" and \"T\" are supported" +
                             //   "OffTargeet PAM: \(offtarget.pam!); Guide PAMs: \(String(pams.map { $0!.sequence}))\n\n")
                        }
                    }
                    
                    off_score =  off_score + offtarget.score! * off_affinity
                    
                   // print("\(xx)::\(res_len):: \(ontarget.pam!) \(ontarget.score!) --- \(offtarget.pam!)  \///(offtarget.score!)  :::::: \(off_affinity)")
                    off_seq = offtarget.querySequence!
                    
                    //XXX: ilap print("Guide: \(on_seq): Off \(off_seq): obj \(ontarget.sequence):off:\(offtarget.score!) - on: - \(off_score) \(off_affinity)")
                    if on_seq != off_seq || xx == res_len - 1  {
                        idx = idx + 1
                        ontarget.score! = ontarget.score!/(ontarget.score!+off_score)
                        //XXX: ilap print("AAAAAA \(on_seq) \(xx) score \(ontarget.score) --- \(off_score): \(ontarget.sequence)")
                        off_score = 0.0
                    }
                    
                    //XXX: ilap //print("ITEM: \(result.sequence!), \(result.querySequence) \(result.score)")
                }

            } else {
                print("No Any Result")
                return false
            }
        } catch let error {
            print ("BioSwift Error: \(error)")
        }
        return true
    }
}
