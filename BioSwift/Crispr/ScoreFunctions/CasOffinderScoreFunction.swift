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

    var sourceName: String? { get set }
    
    var sequence: String? { get set }
    var complement: String? { get set }
    var pam: String? { get set }
    
    // On-target sequence
    // Store the query sequence on which the sequence is compared
    // e.g. score based on this comparison
    var guideSequence: String? { get set }
    var guidePam: String? { get set }

    var strand: String? { get set }
    var location: Int? { get set }
    var length: Int? { get set }
    var score: Double? { get set }

    // These below are currently not used
    var mismatch: Int? { get set }
    var seedMismatch: Int? { get set }
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
        (stdout, stderr, err) = sf.runCommand()
        
        if err == 0 {
            //XXX print("Aggregating Ontargets...")
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
           try fileManager.removeItem(atPath: scoreInputFile)
           try fileManager.removeItem(atPath: scoreOutputFile)
        } catch let error as NSError {
            print("Cannot delete score output file: \(error)")
        }

    }
    
    private func aggregateOnTargets() -> Bool {
        
        let parserFacade = OffTargetParserManagerFacade<TargetProtocol>()
        
        var offtargets: [TargetProtocol]? = nil
        
        do {
            offtargets = try parserFacade.parseFile(parser: parser, scoreOutputFile)
            if offtargets != nil {
                self.results = offtargets!
            } else {
                return false
            }
        } catch let error {
            print ("BioSwift Error: \(error)")
            return false
        }
        
        var on_idx = 0
        var sum_score = 0.0
        var on_len = ontargets.count - 1
        var off_pam = ""
        var ontarget: TargetProtocol? = nil
        
        for (off_idx, offtarget) in self.results.enumerated() {
            
            // FIXME: it is assumed that the ontargets are ordered
            // It won't work if the output is not ordered.
            ontarget = ontargets[on_idx] as! TargetProtocol
            let off_seq = offtarget.guideSequence!
            
            // Skipp the missing ondtargets
            // It's assumed that the Cas-Officner output is always ordered.
            
            while on_idx < on_len && ontarget?.sequence != off_seq {
                if sum_score == 0.0 {
                    ontarget?.score = 1.0
                } else {
                    ontarget?.score! = (ontarget?.score!)!/((ontarget?.score!)!+sum_score)
                    sum_score = 0.0
                }
                on_idx += 1
                ontarget = ontargets[on_idx] as! TargetProtocol
            }
            
            var affinity = ontarget?.score!
            
            if off_pam != offtarget.pam {
                off_pam = offtarget.pam!
                
                // FIXME: If wrong PAM is found then use largest affinity.
                //assertionFailure("\n\nUnconform canonical PAM has detected at location \(offtarget.location)!\n" +
                //   "Only \"N\", \"R\", \"A\", \"G\", \"C\" and \"T\" are supported" +
                //   "OffTargeet PAM: \(offtarget.pam!); Guide PAMs: \(String(pams.map { $0!.sequence}))\n\n")
                //
                if let pam = CrisprUtil.getCompatibleCanonicalPAM(pams: pams, realPAM: offtarget.pam!) {
                    affinity = Double(pam.survival)
                }
            }

            sum_score =  sum_score + offtarget.score! * affinity!
        }
        
        //print("XXXXX: \(i)")
        ontarget?.score! = (ontarget?.score!)!/((ontarget?.score!)!+sum_score)


        //print("SSS \(idx) \(len)")
        if on_idx < on_len {
            for i in on_idx...on_len {
                ontarget = ontargets[i] as! TargetProtocol
                ontarget?.score! = 1.0
            }
        }
        
        return true
    }
}
