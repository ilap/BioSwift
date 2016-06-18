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
    var name: String = "ScoreFunctionTask"
    var progress: Int = 0
    var messages: [String] = []

    var successCommand: Command? = nil
    var failCommand: Command? = nil
    var progressCommand: Command? = nil


    var parameters: ScoreCommandParameterProtocol
    
    func run() {
        print("PRINT COMMANDS AND ARGS")
        print("=======================")
        print("VAR SF: ", self.parameters.sourceFile)
        print("VAR OF: ", self.parameters.outputFile)
        print("VAR IF: ", self.parameters.inputFile)
        print("VAR AC: ", self.parameters.alignCommand)
        print("VAR AA: ", self.parameters.alignArgs)
        print("VAR BC: ", self.parameters.buildCommand)
        print("VAR BA: ", self.parameters.buildArgs)
    }

    init(parameters: ScoreCommandParameterProtocol) {
        self.parameters = parameters
    }

    func runCommand() -> (output: [String], error: [String], exitCode: Int32) {

        var output : [String] = []
        var error : [String] = []

        let task = Task()

        task.launchPath = parameters.alignCommand
        task.arguments = parameters.alignArgs

        let stdout = Pipe()
        task.standardOutput = stdout
        let stderr = Pipe()
        task.standardError = stderr

        task.launch()

        let outdata = stdout.fileHandleForReading.readDataToEndOfFile()
        if var string = String(validatingUTF8: UnsafePointer((outdata as NSData).bytes)) {
            string = string.trimmingCharacters(in: CharacterSet.newlines)
            output = string.components(separatedBy: "\n")
        }

        let errdata = stderr.fileHandleForReading.readDataToEndOfFile()
        if var string = String(validatingUTF8: UnsafePointer((errdata as NSData).bytes)) {
            string = string.trimmingCharacters(in: CharacterSet.newlines)
            error = string.components(separatedBy: "\n")
        }

        task.waitUntilExit()
        let status = task.terminationStatus
        
        return (output, error, status)
    }
    

}
