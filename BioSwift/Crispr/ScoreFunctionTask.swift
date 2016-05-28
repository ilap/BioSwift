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

class ScoreFunctionTask: TaskProtocol {
    var progress: Int = 0
    var messages: [String] = []

    var successCommand: Command? = nil
    var failCommand: Command? = nil
    var progressCommand: Command? = nil

    func run() {
        let to=40000000.0
        let mod=400000
        var sum = 0.0
        var p = 0
        for i in 0...Int(to) {
            if i % mod == 0 {
                p = Int(100*Float(i) / Float(to))
                self.progress = p
                self.progressCommand?.execute()
            }
            sum += 10 * 2
        }
        self.successCommand?.execute()
    }



    var parser: ParserProtocol

    var cmd: String
    var args: [String]?

    init(cmd: String, args: [String], parser: ParserProtocol? = nil) {
        //self.init()
        self.cmd = cmd
        self.args = args


        self.parser = parser!

    }

    func runCommand() -> (output: [String], error: [String], exitCode: Int32) {
        return runCommand(cmd, args: args)
    }

    func runCommand(cmd: String, args: [String]?) -> (output: [String], error: [String], exitCode: Int32) {

        var output : [String] = []
        var error : [String] = []

        let task = NSTask()

        task.launchPath = cmd
        task.arguments = args

        let stdout = NSPipe()
        task.standardOutput = stdout
        let stderr = NSPipe()
        task.standardError = stderr

        task.launch()

        let outdata = stdout.fileHandleForReading.readDataToEndOfFile()
        if var string = String.fromCString(UnsafePointer(outdata.bytes)) {
            string = string.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
            output = string.componentsSeparatedByString("\n")
        }

        let errdata = stderr.fileHandleForReading.readDataToEndOfFile()
        if var string = String.fromCString(UnsafePointer(errdata.bytes)) {
            string = string.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
            error = string.componentsSeparatedByString("\n")
        }

        task.waitUntilExit()
        let status = task.terminationStatus
        
        return (output, error, status)
    }
    

}