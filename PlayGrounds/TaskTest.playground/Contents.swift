//: Playground - noun: a place where people can play

import Foundation

func makeTemp(template: String, body: @noescape (FileHandle, URL) throws -> Void) rethrows {
    
    var url: NSURL? = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(template)
    
    var buf = [Int8](repeating: 0, count: Int(PATH_MAX))
    
    url?.getFileSystemRepresentation(&buf, maxLength: buf.count)
    
    switch mkstemp(&buf) {
    case -1:
        break
    case let fd:
        url = URL(fileURLWithFileSystemRepresentation: buf, isDirectory: false, relativeToURL: nil)
        defer { unlink(&buf) }
        try body(FileHandle(fileDescriptor: fd, closeOnDealloc: true), url! as URL)
    }
}


let task = Task()

task.launchPath = "/Users/ilap/Developer/Dissertation/DesignGuide/Utils/BioTools/ScoreCommands/cas-offinder_singlefile_macos"
task.arguments = ["/tmp/CCCC","C"]

// task.launchPath = "/bin/ls"
// task.arguments = ["-rtl", "/tmp/", "/var/"]

    
makeTemp(template: "TestNSTask.XXXXXX") { handle, url in
    //task.standardOutput
    task.arguments!.append(url.path!)

    print("OUTPUT \(task.arguments)")
    
    task.launch()
    task.waitUntilExit()
        
    handle.seek(toFileOffset: 0)
    let data = handle.readDataToEndOfFile()
    
    guard let string = String(data: data, encoding: String.Encoding.ascii) else {

        return
    }
    
    print("OUTPUT \(task.terminationStatus)")
    print(string)

}

let directory = NSTemporaryDirectory()
let fileName = NSUUID().uuidString

let fullURL = NSURL.fileURL(withPathComponents: [directory, fileName])

