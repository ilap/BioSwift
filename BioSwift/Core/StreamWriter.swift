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

///
/// Implemented from http://stackoverflow.com/questions/24581517/read-a-file-url-line-by-line-in-swift
///
public class StreamWriter {
    
    let encoding: String.Encoding
    
    var fileName: String = ""
    
    let template = "rna_input_file.XXXXXX"
    var fileHandle: FileHandle?
    let delimiterData: Data
    
    convenience init?(url: URL? = nil, delimiter: String = "\n", encoding: String.Encoding = String.Encoding.utf8) {
            self.init(path: url?.path)
    }
    
    init?(path: String? = nil, delimiter: String = "\n", encoding: String.Encoding = String.Encoding.utf8, append: Bool = false) {
        
        if let delimiterData = delimiter.data(using: encoding) {
            self.encoding = encoding
            self.delimiterData = delimiterData
        } else {
            return nil
        }
        
        if let _ = path {
        
            fileName = path!
            
            let fileManager = FileManager.default()
            
            if !fileManager.fileExists(atPath: path!) || !append {
                fileManager.createFile(atPath: path!, contents:nil, attributes:nil)
            }

            if let fileHandle = FileHandle(forWritingAtPath: path!) {
                self.fileHandle = fileHandle
            } else {
                return nil
            }
        } else {
            // generate temp file based on template
            BioSwiftFileUtil.makeTempFile(template: self.template) { handle, url in
                fileHandle = handle
                fileName = url.path!
            }
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
    
    
    private func makeTempDir(template: String, path: String? = nil) -> String! {
        
        var dir: String = NSTemporaryDirectory()
        
        if let _ = path {
            dir = path!
        }
        
        let url: NSURL? = NSURL(fileURLWithPath: dir).appendingPathComponent(template)
        
        
        var buf = [Int8](repeating: 0, count: Int(PATH_MAX))
        
        url?.getFileSystemRepresentation(&buf, maxLength: buf.count)
        
        let result = mkdtemp(&buf)
        if result == nil {
            return nil
        }
        let fm = FileManager.default()
        let tempDirectoryPath = fm.string(withFileSystemRepresentation: result!, length: Int(strlen(result)))
        
        return tempDirectoryPath
    }
}
