//
//  CreateUSIVRequest.swift
//
//
//  Created by Kevin Ravakhah on 2/8/24.
//

import Fluent

struct CreateUSIVRequest: Migration {
    func prepare(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
        return database.schema("requests")
            .id()
            .field("hospital", .string, .required)
            .field("roomNumber", .int, .required)
            .field("callBackNumber", .string, .required)
            .field("notes", .string, .required)
            .field("status", .int, .required)
            .field("userPosted", .uuid, .required)
            .field("userAccepted", .uuid)
            .create()
    }
    
    func revert(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
        return database.schema("requests").delete()
    }
}