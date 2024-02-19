//
//  Request.swift
//
//
//  Created by Kevin Ravakhah on 2/9/24.
//

import Fluent
import Vapor

final class USIVRequest: Model, Content {
    static var schema: String = "requests"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "hospital")
    var hospital: String
    
    @Field(key: "roomNumber")
    var roomNumber: Int
    
    @Field(key: "callBackNumber")
    var callBackNumber: String
    
    @Field(key: "notes")
    var notes: String
    
    @Field(key: "status")
    var status: Int
    
    @Field(key: "userPosted")
    var userPosted: UUID
    
    @Field(key: "userAccepted")
    var userAccepted: UUID?
    
    init() {}
    
    init(id: UUID? = nil, hospital: String, roomNumber: Int, callBackNumber: String, notes: String, status: Int, userPosted: UUID, userAccepted: UUID? = nil) {
        self.id = id
        self.hospital = hospital
        self.roomNumber = roomNumber
        self.callBackNumber = callBackNumber
        self.notes = notes
        self.status = status
        self.userPosted = userPosted
        self.userAccepted = userAccepted
    }
}

/// Represents the expected data for a POST request to create a request.
extension USIVRequest {
    struct Create: Content {
        /// The name of the hospital associated with the request.
        var hospital: String
        /// The room number associated with the request.
        var roomNumber: Int
        /// The callback number associated with the request.
        var callBackNumber: String
        /// Additional notes or comments for the request.
        var notes: String
    }
}