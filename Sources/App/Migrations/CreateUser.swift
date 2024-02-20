//
//  CreateUser.swift
//  
//
//  Created by 陈颢文 on 2/7/24.
//

import Fluent
/// Migration for creating the User table.
struct CreateUser: Migration {
    /// Prepares the database for the migration.
    /// - Parameter database: The database to prepare.
    /// - Returns: An `EventLoopFuture` that resolves to `Void` when the preparation is complete.
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("User")
            .id()
            .field("userName", .string, .required)
            .field("password", .string, .required)
            .field("role", .int, .required)
            .field("deviceToken", .string) 
            .unique(on: "userName")
            .create()
    }

    /// Reverts the migration by deleting all data in the User table.
    /// - Parameter database: The database to revert the migration on.
    /// - Returns: An `EventLoopFuture` that resolves to `Void` when the reversion is complete.
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("User").delete()
    }
    
}