//
//  CreateChat.swift
//
//
//  Created by 陈颢文 on 2/16/24.
//
import Fluent

/// Migration for creating the "chats" table in the database.
struct CreateChat: Migration {
    /// Prepares the migration by defining the table schema and its fields.
    /// - Parameter database: The database connection.
    /// - Returns: An `EventLoopFuture` that resolves to `Void` when the migration is prepared.
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("chats")
            .id()
            .field("requestID", .uuid, .required)
            .field("message", .string, .required)
            .field("sentAt", .datetime, .required)
            .field("userName", .string, .required)
            .create()
    }
    
    /// Reverts the migration by deleting the "chats" table.
    /// - Parameter database: The database connection.
    /// - Returns: An `EventLoopFuture` that resolves to `Void` when the migration is reverted.
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("chats").delete()
    }
}
