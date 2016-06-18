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

protocol Target {
    var loci: Int { get set }
    var length: Int { get set }
    var endLoci: Int { get set }
}

protocol ScoreFunctionProtocol {
//    associatedtype T
    var parser: ParserProtocol { get set }
    var formatter: InputFormatterProtocol { get set }
//    func score(genome: SeqRecord, guideRNAs: [String], maskedPam: String,) -> [T]?
}

protocol ScoreCommandParameterProtocol {
    
    var buildCommand: String { get set }
    var alignCommand: String { get set }
    
    var buildArgs: [String] { get set }
    var alignArgs: [String] { get set }
    
    var sourceFile: String { get set }
    var inputFile: String  { get set }
    var outputFile: String  { get set }
    var indexPostfix: String { get set }
    

    
    func parseCommand() -> String
}

class AbstractCommandParameters: ScoreCommandParameterProtocol {
    let bundle = Bundle(for: AbstractCommandParameters.self)
    
    var buildCommand: String = ""
    var alignCommand: String = ""
    
    var buildArgs: [String] = []
    var alignArgs: [String] = []
    
    var sourceFile: String
    var inputFile: String
    var outputFile: String
    var indexPostfix: String = "_idx"
    
    var commandArgs: String = ""
    var extraArgs: String = ""
    
    init(sourceFile: String, inputFile: String, outputFile: String) {
        self.sourceFile = sourceFile
        self.inputFile = inputFile
        self.outputFile = outputFile
        

#if os(Linux)
        self.bundle = "./ScoreCommands"
#endif
        
        self.initialise()
    }
    
    private func initialise() {

        // override
    }
    
    func parseCommand() -> String {
        return "AAAA"

    }

}

class BowtieCommandParameters: AbstractCommandParameters {
    
    override func initialise() {
#if !os(Linux)
        self.buildCommand = "bowtie-build-s_linux_64"
        self.alignCommand = "bowtie-align-s_linux_64"
#else
    self.buildCommand = "bowtie-build-s_macos"
    self.alignCommand = "bowtie-align-s_macos"
#endif
        if let basename = try? URL(fileURLWithPath: self.sourceFile).deletingPathExtension().lastPathComponent {
            self.indexPostfix = basename! + "_bowtie" + self.indexPostfix
        }
        self.buildCommand = "\(bundle)/\(buildCommand)"
        self.buildArgs.append("-f \(self.sourceFile) \(self.indexPostfix)")
        self.alignCommand = "\(bundle)/\(buildCommand)"
        self.alignArgs.append("-c -f \(self.indexPostfix) -f \(self.inputFile)")
    }
}

class BowtieInputFormatter: InputFormatterProtocol {
private var fileDescriptor: Int32 = -1
    
    var initialised: Bool {
        get {
            return self.fileDescriptor != -1
        }
    }
    
    var fileURL: URL?
    
    init() {
        self.initialise()
        
    }
    
    deinit {
        if self.fileDescriptor != -1 {
            close(self.fileDescriptor)
            self.fileDescriptor = -1
        }
    }
    
    private func initialise() {
        let url: NSURL? = try? URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("rna_input_file.XXXXXX")
        
        var buf = [Int8](repeating: 0, count: Int(PATH_MAX))
        
        url?.getFileSystemRepresentation(&buf, maxLength: buf.count)
        
        self.fileDescriptor = mkstemp(&buf)
        
        if self.fileDescriptor != 1 {
            #if swift(>=3.0)
                self.fileURL = URL(fileURLWithFileSystemRepresentation: buf, isDirectory: false, relativeToURL: nil) as URL
            #elseif swift(>=2.2)
                self.fileURL = URL(fileURLWithFileSystemRepresentation: buf, isDirectory: false, relativeToURL: nil)
            #endif
        }
    }
    
    func write(_ fileName: String?, ontargets: [String]) -> Bool {
        print("Write Guide RNAs to file")
        return true
    }
    
    func writeOntargetsAsFastaFile(_ usedPAMs: [String], start: Int, end: Int) -> String? {
        
        let result: String? = ""
        
        /*let temp = try! URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("rna_input_file.XXXXXX")
        
        var buf = [Int8](repeating: 0, count: Int(PATH_MAX))
        (temp as NSURL).getFileSystemRepresentation(&buf, maxLength: buf.count)
        
        let fd = mkstemp(&buf)
        
        var url: URL? = nil
        
        if fd != -1 {
            
            // Create URL from file system string:
            
            url = URL(fileURLWithFileSystemRepresentation: buf, isDirectory: false, relativeTo: nil)
            //let u = URL(UnsafePointer<Int8>)

            if let temp_url = url, let _ = temp_url.path {
                result = temp_url.path
                
                print("TEMPFILE IS: ", temp_url.path!)
            } else {
                print("NO URL")
            }
            
        } else {
            print("FATAL ERROR: " + String(strerror(errno)))
        }
        
       // let ontargets = getOnTargets(usedPAMs, start: start, end: end)
        
       // writeGuideRNAToURL(url!, rnaTargets: ontargets!, name: record.id)
        
        close(fd)*/
        
        return result
        
    }
    
    private func writeGuideRNAToURL(_ url: URL, rnaTargets: [Int], name: String? = nil) {
        
        print ("DOOOOOOOOOIIIIIIIIIIIIIT")
        
        
        var organismName = ""
        if let _ = name {
            organismName = name!
        }
        var result: [String] = []
        var validLocation = 0
        var strand = "+"
        var pamPos = 0
        var s = 0
        var e = 0
        
        var data: Data = "STRING.....".data(using: String.Encoding.utf8)!
        let resultData = NSMutableData()
        
        var dataStr: NSString = ""
        
        let tstart = Date()
        
       /* for pamLocation in rnaTargets {
            
            //print ("PAMLOCATION \(pamLocation)")
            
            if  pamLocation >= 0 {
                validLocation = pamLocation
                pamPos = validLocation
                strand = "+"
                s=Int(pamPos) - spacerLength
                e=Int(pamPos) + pamLength - 1
                //result.append("\(organismName):\(strand):\(s)-\(e):\(record.seq.sequence[s...e])")
                dataStr = "\(organismName):\(strand):\(s)-\(e):\(record.seq.sequence[s...e])\n" as NSString
                data = dataStr.dataUsingEncoding(NSUTF8StringEncoding)!
                resultData.appendData(data)
                
            } else {
                validLocation = -pamLocation
                pamPos = validLocation + pamLength
                strand = "-"
                s=Int(pamPos) - pamLength
                e=Int(pamPos) + spacerLength - 1
                
                dataStr = "\(organismName):\(strand):\(s)-\(e):\(record.seq.sequence[s...e].complement())\n" as NSString
                
                
                data = dataStr.dataUsingEncoding(NSUTF8StringEncoding)!
                resultData.appendData(data)
                
            }
            //print ("XXXX: \(dataStr)")
            
            //writeToURL(url, options: .AtomicWrite)
        }*/
        //try? resultData.writeToURL(url, atomically: false)
        
        //let tend = NSDate()
        //let timeInterval = tend.timeIntervalSinceDate(tstart)
        //print("Time to evaluate printing gRNA \(timeInterval) seconds")
        
        //dump(result)
        //print(result.joinWithSeparator("\n"))
        
    }

}

class BowtieScoreFunction: ScoreFunctionProtocol, TaskProtocol  {
    
    var outputURL: URL?

    var name: String = "Bowtie Score Task"
    var progress: Int = 0
    var messages: [String] = []
    
    var successCommand: Command? = nil
    var failCommand: Command? = nil
    var progressCommand: Command? = nil
    
    func run() {
        
        print("\(name) is Running")
        
    }
    
    var parser: ParserProtocol
    var formatter: InputFormatterProtocol
    var parameters: ScoreCommandParameterProtocol

    init(sourceFile: String, inputFile: String, outputFile: String) {
        self.parser = BowtieOutputParser()
        self.formatter = BowtieInputFormatter()
        self.parameters = BowtieCommandParameters(sourceFile: sourceFile, inputFile: inputFile, outputFile: outputFile)
    }
    
    private func formatter(_ string: String) {
        
    }
    
}

