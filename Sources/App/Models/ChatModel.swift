import Foundation
import Fluent
import Vapor

/// Represents a message in the application.
final class ChatModel: Model, Content {
    
    static let schema: String = "chats"
    
    @ID var id: UUID?
    @Field(key: "requestID") var requestID: UUID?
    @Field(key: "message") var message: String
    @Timestamp(key: "sentAt", on: .create)
    var sentAt: Date?
    @Field(key: "userName") var userName: String?
    
    init() {}
    
    /// Initializes a new instance of the Message class.
    /// - Parameters:
    ///   - id: The unique identifier of the message.
    ///   - requestID: The unique identifier of the associated request.
    ///   - message: The content of the message.
    ///   - userUUID: The unique identifier of the user who sent the message.
    init(id: UUID? = nil, requestID: UUID, message: String, userName: String) {
        self.id = id
        self.requestID = requestID
        self.message = message
        self.userName = userName
    }
}

extension ChatModel {
    struct Create: Content {
        /// The content of the message.
        var message: String
        var userName: String
    }
}
