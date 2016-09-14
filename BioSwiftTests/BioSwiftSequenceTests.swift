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
import XCTest

@testable import BioSwift


public class BioSwiftSequenceTests: XCTestCase {
    
#if os(Linux)
    public var allTests: [(String, () throws -> Void)] {
    return [
    ("testOnTargetsInSequence", testOnTargetsInSequence),
    ("testSequenceReverseComplement", testSequenceReverseComplement),
    ("testSequencePerformance", testSequencePerformance),
    ]
    }
#else

    override public func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override public func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    #endif
    
    func testOnTargetsInSequence() {
                              // 0123456789012345678901
        var seq = Seq(sequence: "ACGTACGTACGGGCTGAGACGT")
        var pams = ["NGG"]//, "NAG"]
        var rec = SeqRecord(id: "test", seq: seq)
        var cu = CrisprUtil(record: rec,  parameters: DesignParameters())
        
        // var res = seq.getOnTargets(pams, start: 0, end: Int(seq.length))
        var res = cu.getOnTargetsLocation(pams, start: 0, end: Int(seq.length))

        assert (res == nil || res!.sorted() == [9, 10, 15, -13].sorted())


        res = cu.getOnTargetsLocation(pams.map { $0.reverseComplement() }, start: 0, end: Int(seq.length))
        rec = SeqRecord(id: "test", seq: seq)
        cu = CrisprUtil(record: rec,  parameters: DesignParameters())
        assert (res == nil || res!.sorted() == [-9, -10, -15, 13].sorted())
        
                          // 012345678901234567
        seq = Seq(sequence: "ATTCCAGAGCAATCCCGT")
        pams = ["NTTNNA", "ANNAAT", "GCNNTC"]
        rec = SeqRecord(id: "test", seq: seq)
        cu = CrisprUtil(record: rec, parameters: DesignParameters())
        
        res = cu.getOnTargetsLocation(pams, start: 0, end: Int(seq.length))
        print ("RES: \(res)")
        assert (res == nil || res!.sorted() == [0, 7, 8])

        
                          // 0123456789012345678901
        seq = Seq(sequence: "ACGTACGTACATACTGATACGT")
        rec = SeqRecord(id: "test", seq: seq)
        cu = CrisprUtil(record: rec, parameters: DesignParameters())
        
        res = cu.getOnTargetsLocation(pams, start: 0, end: Int(seq.length))
        assert(res == nil)

    }
    
    func testSequenceSubscript() {
        let seq = Seq(sequence: "ACGTACGTACGGGCTGAGACGT")
        
        assert( seq[0] == "A")
        assert( seq[1] == Character("C"))
        assert( seq[0...2] == "ACG")
        assert( seq[0...2].reverseComplement() == "CGT")
        assert( seq[0...2].complement() == "TGC")
    }

    func testSequenceReverseComplement() {

        let pams = ["NTTNNA", "ANNAAT", "GCNNTC"]
        let reversePams = pams.map { $0.reverseComplement() }

        assert(reversePams == ["TNNAAN", "ATTNNT", "GANNGC"])

    }

    func testOffTargetsInSequence() {
        let genome =  Seq(sequence: "AAAAAAAAAAAAAAAAAAAAAAAAAAGTTTTTTTTTTTTTTTTTTTTTTTTTTTTTGGCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCAG")
           //01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890

        let record = SeqRecord(id: "TestRecord", seq: genome)
        let onTargetLoci = 50
        let onTargetLength = 10

        //let usedPAMs = ["NGG"]
        let allPAMs = ["NGG", "NGA", "NAG", "NAA"]

        ////let crisprUtil = CrisprUtil(record: record, parameters: allPAMs)
        //crisprUtil.getScoredOfftargets(onTargetLoci, targetLength: onTargetLength)


        //print("MASKEDlllll PAM: \(crisprUtil.maskedPAM)")

    }

    func testSequencePerformance() {
        /*
         var start = NSDate()
         //var seqIO = SeqIO(path: "/Users/ilap/Developer/Dissertation/DesignGuide/Utils/Sequences/Bacillus_subtilis-ATCC6051_whole_genome/sequence.fasta.txt")
         guard let seqrecords = try SeqIO.parse(parameters.source) else { return }

         //print("SEQRECORD.... \(seqrecords)")
         let seqRecord = seqrecords[0]!

         var end = NSDate()
         var timeInterval: Double = end.timeIntervalSinceDate(start)

         print("Timeinterval \(timeInterval)")

         start = NSDate(); print ("GC Content \(seqRecord.gcContent.format(".2"))"); end = NSDate(); timeInterval  = end.timeIntervalSinceDate(start);print("Timeinterval \(timeInterval)")
         start = NSDate(); print ("GC Content \(seqRecord.bases)"); end = NSDate(); timeInterval  = end.timeIntervalSinceDate(start);print("Timeinterval \(timeInterval)")
         start = NSDate(); print ("GC Content \(seqRecord.length)"); end = NSDate(); timeInterval  = end.timeIntervalSinceDate(start);print("Timeinterval \(timeInterval)")

         print (seqRecord[15] as String)

         start = NSDate()
         let hash = seqRecord.seq.sequence.hash
         print ("HASVALUE: \(String(hash, radix: 16))")
         end = NSDate()
         timeInterval  = end.timeIntervalSinceDate(start);print("Timeinterval \(timeInterval)")
         //print ("Bases \(seqRecord.bases)")
         //print ("Length \(seqRecord.length)")
         */
    }
    
}
