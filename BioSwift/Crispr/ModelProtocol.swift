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

public protocol PAMProtocol {
    var id: Int? { get set }
    var nuclease_id: Int { get set }
    var sequence: String { get set }
    var survival: Float { get set }
}


public protocol NucleaseProtocol  {
    var id: Int? { get set }
    var name: String  { get set }
    var spacer_length: Int { get set }
    var sense_cut_offset: Int { get set }
    var antisense_cut_offset: Int { get set }
    var downstream_target: Bool { get set }
    var descr: String { get set }
}


public protocol DesignSourceProtocol {
    var id: Int? { get set }
    var name: String  { get set }
    var descr: String  { get set }
    var path: String  { get set }
    var sequence_length: Int { get set }
    var sequence_hash: Int { get set }
}

public protocol DesignTargetProtocol {
    var id: Int? { get set }
    
    var sesign_source_id: Int { get set }
    var design_application_id: Int { get set }
    var name: String  { get set }
    
    var location: Int { get set }
    var length: Int { get set }
    var offset: Int { get set }
    var type: String  { get set }
    var descr: String  { get set }
}


public protocol DesignApplicationProtocol {
    var id: Int? { get set }
    var name: String  { get set }
    var descr: String  { get set }
}


public protocol RNAOntargetProtocol {
    var id: Int? { get set }
    var model_target_id: Int { get set }
    var nuclease_id: Int { get set }
    var pam: String  { get set }
    var pam_location: Int { get set }
    var score: Float { get set }
    var spacer_length: Int { get set }
    var seed_length: Int { get set }
    var at_offset_position: Bool { get set }
    var on_sense_strand: Bool { get set }
}


public protocol RNAOfftargetProtocol {
    var id: Int? { get set }
    
    var on_target_id: Int { get set }
    var pam_location: Int { get set }
    var score: Float { get set }
    var on_sense_strand: Bool { get set }
    // Off target maybe checked at on target position if it's a KI or single point mutation editing.
    var at_on_target: Bool { get set }
}


public protocol UserProtocol {
    var id: Int? { get set }
    var login: String  { get set }
    var first_name: String  { get set }
    var last_name: String  { get set }
    
}

public protocol ExperimentProtocol {
    var id: Int? { get set }
    var user_id: Int { get set }
    var title: String  { get set }
    var date: Date { get set }
    var validated: Date { get set }
    var descr: String  { get set }
}


public protocol ExperimentGuideRNAProtocol {
    var id: Int? { get set }
    var experment_id: Int { get set }
    var on_target_id: Int { get set }
    var title: String  { get set }
    var validated: Date { get set }
}
