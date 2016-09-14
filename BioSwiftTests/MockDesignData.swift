//
//  MockDesignData.swift
//  BioSwift
//
//  Created by Pal Dorogi on 1/07/2016.
//  Copyright © 2016 Pal Dorogi. All rights reserved.
//

import Foundation


class DesignParameters: DesignParameterProtocol {
    var seedLength: Int = 10
    var spacerLength: Int = 20
    
    var senseCutOffset: Int? = 4
    var antiSenseCutOffset: Int? = 4

    var targetOffset: Int = 0
    var pamLength: Int = 3

}

class MockPAM: PAMProtocol {
    var id: Int? = 1
    var nuclease_id: Int = -1
    var sequence: String = ""
    var survival: Float = 0.0
    
    static var pams: [PAMProtocol?] = []
    
    init (sequence: String, survival: Double) {
        self.sequence = sequence
        self.survival = Float(survival)
    }
    
    static func getPAMs() -> [PAMProtocol?] {
        // pams.append(MockPAM(sequence: "NGAN", survival: 0.70 ))
        // pams.append(MockPAM(sequence: "NGGN", survival: 0.70))
        pams.append(MockPAM(sequence: "NGG", survival: 0.68 ))
        pams.append(MockPAM(sequence: "NAG", survival: 0.0132 ))
        pams.append(MockPAM(sequence: "NGA", survival: 0.002 ))
        pams.append(MockPAM(sequence: "NAA", survival: 0.0007))
        return pams
    }
}

class MockDesignTarget: DesignTargetProtocol {
    var id: Int? = 1
    
    var design_source_id: Int = 0
    var design_application_id: Int = 0
    var name: String  = ""
    
    var location: Int = 0
    var length: Int = 0
    var offset: Int = 40
    var type: String  = ""
    var descr: String  = ""
    
    static var designTargets: [DesignTargetProtocol?] = []
    
    init (name: String, location: Int, length: Int, offset: Int) {
        self.name = name
        self.location = location
        self.length = length
        self.offset = offset
    }
    
    static func getDesignTargets() -> [DesignTargetProtocol?] {
        designTargets.append(MockDesignTarget(name:  "20-120", location:  20, length:  100, offset: 20))
        //designTargets.append(MockDesignTarget(name:  "100-200", location:  100, length:  100, offset: 20))
        //designTargets.append(MockDesignTarget(name:  "400-500", location:  400, length:  500, offset: 30))
        //designTargets.append(MockDesignTarget(name: "2000-2200", location: 2000, length: 200, offset: 40))
        //designTargets.append(MockDesignTarget(name: "3000-3100", location: 3000, length: 100, offset: 50))
        return designTargets
    }
}

protocol DesignSourceModelProtocol {
    var seqRecord: SeqRecord? { get set }
}

class MockDesignSource: DesignSourceProtocol, DesignSourceModelProtocol {

    var id: Int? = 0
    var name: String = ""
    var descr: String = ""
    var path: String = ""
    var sequence_length: Int = 0
    var sequence_hash: Int = 0
    
    var seqRecord: SeqRecord?
    
    static var designSources: [DesignSourceProtocol?] = []
    
    init (record: SeqRecord) {
        self.seqRecord = record
        self.name = record.id
        self.path = record.path!
        self.sequence_length = record.length
    }
    
    static func getDesignSources(path: String) -> [DesignSourceProtocol?] {
        
        let records = try! SeqIO.parse(path)
        
        if !records!.isEmpty {
            for record in records! {
                designSources.append(MockDesignSource(record: record!))
            }
        }
        return designSources
    }
}
