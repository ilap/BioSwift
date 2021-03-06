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

public class SeqIO {
    
    
    public static func parse(_ path: String?) throws -> [SeqRecord?]? {
        
        guard let _ = path, let contents = try? String(contentsOfFile: path!,  encoding: String.Encoding.ascii) else { return nil }
        
        var records : [SeqRecord?] = []
        var seqRecord : SeqRecord?
        
        var hasRecord = false
        for line in contents.components(separatedBy: "\n") {
            if line.isEmpty {
                continue
            }
            
            if line[0] == ">" {
                var id = ""
                if let idx = line.characters.index(of: " ") {
                    id = line[line.characters.index(after: line.startIndex) ..< idx]
                } else {
                    id = line
                }
                
                if hasRecord {
                    (records.last! as SeqRecord?)!.initialised = true
                } else {
                    hasRecord = true
                }
                
                // Process the existing record if there is any
                //
                //let lastRecord = records!.last
                
                seqRecord = SeqRecord(id: id, path: path)
                records.append(seqRecord!)

            } else {
                // slower let tline = line.stringByReplacingOccurrencesOfString(" ", withString: "")
                let tline = line.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
                
                seqRecord!.append(tline)
            }
        }
        
        // It has at least one SeqRecord
        if hasRecord {
            (records.last! as SeqRecord?)!.initialised = true
        } else {
            throw BioSwiftError.fastaError("No any FASTA sequence found int the sequence file: \(path)")
        }
        
        return records
    }    
}
