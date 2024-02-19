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

}
 