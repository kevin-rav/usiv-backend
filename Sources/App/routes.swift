import Fluent
import Vapor

struct SocketConnection: Identifiable {
    let id: UUID
    var ws: WebSocket
}

// Using [String: [SocketConnection]] as the type is more descriptive and avoids force unwrapping.
var allSockets = [String: [SocketConnection]]()

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }
    
    // Register controllers.
    try app.register(collection: USIVRequestController())
    try app.register(collection: UserController())
    
    app.get("chats", ":requestUUID") { req -> EventLoopFuture<[ChatModel]> in
        guard let requestUUIDStr = req.parameters.get("requestUUID"), let requestUUID = UUID(uuidString: requestUUIDStr) else {
            throw Abort(.badRequest)
        }
        return ChatModel.query(on: req.db)
            .filter(\.$requestID == requestUUID)
            .sort(\.$sentAt, .descending)
            .limit(100)
            .all()
    }


    // Define a WebSocket route.
    app.webSocket(":requestUUID") { req, ws in
        guard let requestUUID = req.parameters.get("requestUUID") else {
            // Handle the case where requestUUID is not present.
            ws.close(code: .unexpectedServerError)
            return
        }

       
        var room = allSockets[requestUUID, default: []]

        // Create a new SocketConnection.
        let socketConnection = SocketConnection(id: UUID(), ws: ws)
        room.append(socketConnection)
        allSockets[requestUUID] = room

        ws.onText { ws, text in
            // Get user name from header.
            let userName = req.headers.first(name: "userName") ?? "Unknown User"
            
            Task {
                let chatModel = ChatModel(
                    requestID: UUID(uuidString: requestUUID) ?? UUID(),
                    message: text,
                    userName: userName
                )
                
                // Reference the global allSockets directly to get the latest room connections.
                if let roomConnections = allSockets[requestUUID] {
                    roomConnections.forEach { socket in
                        if socket.id != socketConnection.id {
                            socket.ws.send(text)
                            print("message Sent")
                        }
                    }
                }
                
                do {
                    try await chatModel.save(on: req.db) // Await the save operation
                } catch {
                    print("Failed to save chat message: \(error)")
                    // Optionally, inform the user about the failure.
                }
            }
        }

        // Handle WebSocket closure and remove the connection from the room.
        ws.onClose.whenComplete { _ in
            allSockets[requestUUID]?.removeAll { $0.id == socketConnection.id }
        }
    }
    
}
