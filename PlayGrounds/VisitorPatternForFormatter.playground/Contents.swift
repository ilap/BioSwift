import Foundation
//import BioSwift

//import PlaygroundSupport

//PlaygroundPage.current.needsIndefiniteExecution = true

///
/// Implemented from http://stackoverflow.com/questions/24581517/read-a-file-url-line-by-line-in-swift
///
public class StreamWriter {
    
    let encoding: String.Encoding
    
    var fileHandle: FileHandle?
    let delimiterData: Data
    
    
    convenience init?(url: URL, delimiter: String = "\n", encoding: String.Encoding = String.Encoding.utf8) {
        self.init(path: url.path!)
    }
    
    init?(path: String, delimiter: String = "\n", encoding: String.Encoding = String.Encoding.utf8) {
        
        let fileManager = FileManager.default
        
        if !fileManager.fileExists(atPath: path) {
            fileManager.createFile(atPath: path, contents:nil, attributes:nil)
        }
        

        if let fileHandle = FileHandle(forWritingAtPath: path) {
            self.fileHandle = fileHandle
        } else {
            return nil
        }
        
        
        if let delimiterData = delimiter.data(using: encoding) {
            self.encoding = encoding
            self.delimiterData = delimiterData
        } else {
            return nil
        }
    }
    
    deinit{
        self.close()
    }
    
    public func writeLine(message: String) {
        
        if let data = message.data(using: encoding) {
            fileHandle?.write(data)
            fileHandle?.write(delimiterData)
        }
    }
    
    public func write(message: String) {
        
        if let data = message.data(using: encoding){
            fileHandle?.write(data)
        }
    }
    
    public func close(){
        if let _ = fileHandle {
            fileHandle?.closeFile()
            fileHandle = nil
        }
    }
}

///
/// Target protocol for
///
protocol OnTargetProtocol {
    var sequence: String { get set }
    var pam: String { get set }
    var strand: String { get set }
    var position: Int { get set }
    var length: Int { get set }
}

class Target: OnTargetProtocol {
    var sequence: String = "CTGAAATGTTATGGTT"
    var pam: String = "CGG"
    var name: String = "ID1234"
    var strand: String = "+"
    var position: Int = 145000
    var length: Int = 10000
    
}


extension Target: VisitableProtocol {

    var text: String {
        get {
            return sequence
        }
        set {
            sequence = newValue
        }
    }
    
    func accept(visitor: VisitorProtocol) {
        visitor.visit(bodyPart: self)
    }
}

///
/// Visitor Design pattern
///
protocol VisitorProtocol {
    var message: String { get set }
    
    func visit(headerPart: VisitableProtocol)
    func visit(bodyPart: VisitableProtocol)
    func visit(footerPart: VisitableProtocol)
}


protocol VisitableProtocol {
    var text: String { get set }
    func accept(visitor: VisitorProtocol)
}


///
/// Implements Visitable Protocol for formatting PWA inputs.
///
class InitialTarget: VisitableProtocol {
    var text: String = "NNNNNNNNNNNNNNCGG"
    func accept(visitor: VisitorProtocol) {
        visitor.visit(headerPart: self)
    }
}

class FinalTarget: VisitableProtocol {
    var text: String = "$$$$$END"
    func accept(visitor: VisitorProtocol) {
        visitor.visit(footerPart: self)
    }
}


///
/// Implements Visitor protocol
///
class AnyStreamInputFormatter: VisitorProtocol {
    
    private var fileName: String
    private var streamWriter: StreamWriter?
    
    var _message: String = ""
    var message: String {
        get {
            // Only last line is supported.
            return _message
        }
        
        set {
            _message = newValue
            streamWriter?.writeLine(message: _message)
        }
    }
    
    init?(path: String) {

        if let streamWriter = StreamWriter(path: path) {
            self.streamWriter = streamWriter
            self.fileName = path
        } else {
            // FIXME: Throw and error
            return nil
        }
    }
    
    deinit {
        streamWriter?.close()
    }
    
    func visit(headerPart: VisitableProtocol) {
        // FIXME: Throw and error as this code should not be reachead..
        assertionFailure("This code should not be reachead" + #file + ":" + String(#line))
    }
    
    func visit(bodyPart: VisitableProtocol) {
        // FIXME: Throw and error as this code should not be reachead..
        assertionFailure("This code should not be reachead" + #file + ":" + String(#line))    }
    
    func visit(footerPart: VisitableProtocol) {
        // FIXME: Throw and error as this code should not be reachead..
        assertionFailure("This code should not be reachead" + #file + ":" + String(#line))    }
}


class BowtieInputFormatter: AnyStreamInputFormatter {


    override func visit(headerPart: VisitableProtocol) {
        message = headerPart.text
    }
    
    override func visit(bodyPart: VisitableProtocol) {
        let ontarget = bodyPart as! Target
        message = ">" + ontarget.name + "-" + String(ontarget.position) + "-" + String(ontarget.length)
        message = ontarget.sequence + ontarget.pam
    }
    
    override func visit(footerPart: VisitableProtocol) {
        message = "THIS IS THE ENDXX" + footerPart.text
    }
}


///
/// Implelents Client class for Visitor Design Pattern.
///
class ScoreFunctionManager {
    
    // ontargets...
    private var visitorParts: [VisitableProtocol]  = []
    
    init() {
        visitorParts.append(InitialTarget())
        visitorParts.append(Target())
        visitorParts.append(Target())
        visitorParts.append(Target())
        visitorParts.append(FinalTarget())
    }
    
    func accept(visitor: VisitorProtocol) {
        
        for part in visitorParts {
            part.accept(visitor: visitor)
        }
    }
}


let bsf = ScoreFunctionManager()

let formatterVisitor = BowtieInputFormatter(path: "/tmp/CCC")

bsf.accept(visitor: formatterVisitor!)


/*
/// Write Output Stream
var myString = "Hello world!\n"
var outputStream = NSOutputStream(toFileAtPath: "/tmp/CCC", append: false)
var data: Data = myString.data(using: String.Encoding.utf8)!

var buffer = [UInt8](repeating:0, count:data.count)
//var b = UnsafeMutablePointer<UInt8>()

//data.getBytes(&buffer)

data.copyBytes(to: &buffer, count: data.count)

outputStream?.open()

outputStream?.write(&buffer, maxLength: data.count)
outputStream?.write(&buffer, maxLength: data.count)
outputStream?.write(&buffer, maxLength: data.count)
outputStream?.write(&buffer, maxLength: data.count)
outputStream?.write(&buffer, maxLength: data.count)
outputStream?.write(&buffer, maxLength: data.count)
outputStream?.write(&buffer, maxLength: data.count)
outputStream?.write(&buffer, maxLength: data.count)
outputStream?.close()

*/










