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
/// File utilities to handle files/directories for BioSwift.
///
public class BioSwiftFileUtil {

    let fileManager: FileManager


    public init() {
        fileManager = FileManager.default
    }

    ///
    /// Check whether the existence of the path.
    /// Results: True - exist and a directory
    /// False - exist but it's not a directory
    /// nil - Do not exits.
    ///
    public func isDirectory(_ path: String) -> Bool? {
        var isDir: ObjCBool = false

        if fileManager.fileExists(atPath: path, isDirectory: &isDir) {
            return Bool(isDir)
        } else {
            return nil
        }
    }

    private func hasPreDefinedSuffix(_ file: String, suffixes: [FileExtensions]) -> Bool {
        var result = false

        if suffixes.isEmpty {
            return true
        }

        for suffix in suffixes {
            if file.hasSuffix(suffix.rawValue) {
                result = true
                break
            }
        }
        return result

    }
    ///
    /// TODO: implement extensions
    ///
    public func getFilesFromPath(_ path: String, extensions: [FileExtensions] = FileExtensions.allValues) throws -> [String]  {

        var result: [String] = []
        //let fileManager = NSFileManager.defaultManager()

        if let isDir = isDirectory(path) {
            if isDir {
                //let enumerator:NSDirectoryEnumerator = fileManager.enumeratorAtPath(source)
                //while let element = enumerator?.nextObject() as? String {
                let files = try fileManager.contentsOfDirectory(atPath: path)
                for file in files {
                    //Add all files but direcotries from the path...
                    // Handle Unix hidden files..
                    let fileName = path+"/"+file

                    // Do not parse hidden files in the direcotry.
                    // isDirectory can be unwrapped as it must be a file of directory.
                    if !isDirectory(fileName)! && !file.hasPrefix(".") &&
                        hasPreDefinedSuffix(file, suffixes: extensions){
                        //print("ITIS FILE: \(fileName)")
                        result.append(fileName)
                    } else {
                        throw BioSwiftError.fileError("File \"\(file)\" does not conform the requirements e.g. Fasta file /w  \(extensions) extension")
                    }
                }

            } else {
                result.append(path)
            }
        } else {
            //TODO Throw an error.
            throw  BioSwiftError.fileError("Error parsing file or directory.: '\(path)'")
        }

        return result
    }
    
    public class func generateTempFileName() -> String? {
        let directory = NSTemporaryDirectory()
        let fileName = NSUUID().uuidString
    
        return NSURL.fileURL(withPathComponents: [directory, fileName])?.path
    }
    
    public class func makeTempFile(template: String, path: String? = nil, body: @noescape (FileHandle, URL) throws -> Void) rethrows {
        
        var dir: String = NSTemporaryDirectory()
        
        if let _ = path {
            dir = path!
        }
        
        let url: NSURL? = NSURL(fileURLWithPath: dir).appendingPathComponent(template)
        
        var buf = [Int8](repeating: 0, count: Int(PATH_MAX))
        
        url?.getFileSystemRepresentation(&buf, maxLength: buf.count)
        
        let fd = mkstemp(&buf)
        
        if fd != -1 {
            
            let fileURL = URL(fileURLWithFileSystemRepresentation: buf, isDirectory: false, relativeToURL: nil)
            
            defer {
                unlink(&buf)
            }
            try body(FileHandle(fileDescriptor: fd, closeOnDealloc: true), fileURL)
        }
    }
}
