//
//  UserController.swift
//
//
//  Created by Kevin Ravakhah on 2/8/24.
//

import Vapor
import Fluent

struct UserController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let usersRoute = routes.grouped("users")
        usersRoute.post(use: create)

        usersRoute.get(use: index)
        
        let passwordProtected = usersRoute.grouped(User.authenticator())
        passwordProtected.post("login", use: login)

        passwordProtected.put("registerDeviceToken", use: registerDeviceToken)

    }

    func index(req: Request) throws -> EventLoopFuture<[User]> {
        return User.query(on: req.db).all()
    }
    
    func create(req: Request) throws -> EventLoopFuture<User> {
        try User.Create.validate(content: req)
        let create = try req.content.decode(User.Create.self)
        guard create.password == create.confirmPassword else {
            throw Abort(.badRequest, reason: "Passwords did not match")
        }
        
        let user = try User(
            userName: create.userName,
            password: Bcrypt.hash(create.password),
            role: create.role 
        )
        
        return user.save(on: req.db).map { user }
    }
    
    func login(req: Request) throws -> User {
        try req.auth.require(User.self)
    }

    func registerDeviceToken(req: Request) throws -> EventLoopFuture<User> {
        // Log the authenticated user
        if let user = try? req.auth.require(User.self) {
            print("Authenticated user: \(user)")
        } else {
            print("User authentication failed")
        }
        
        // Decode the device token from the request body
        let deviceTokenData = try req.content.decode(DeviceTokenData.self)
        
        // Update the user's device token field with the received token
        if var user = try? req.auth.require(User.self) {
            user.deviceToken = deviceTokenData.token
            
            // Save the updated user to the database
            return user.save(on: req.db)
                .map { user }
                .flatMapErrorThrowing { error in
                    // Handle database errors
                    print("Failed to save user: \(error)")
                    throw error
                }
        } else {
            throw Abort(.unauthorized)
        }
    }



}
 