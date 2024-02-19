//
//  USIVRequestController.swift
//
//
//  Created by Kevin Ravakhah on 2/8/24.
//

import Fluent
import Vapor

struct USIVRequestController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let requests = routes.grouped("requests")
        let passwordProtected = requests.grouped(User.authenticator())

        // view and create
        requests.get(use: index)
        passwordProtected.post(use: create)

        // for different views
        requests.get("available", use: availableRequests)
        passwordProtected.get("userPosted", use: requestsByUserPosted)
        passwordProtected.get("userAccepted", use: requestsByUserAccepted)

        // to update requests 
        passwordProtected.put("accept", ":requestID", use: acceptRequest)
        requests.put("cancel", ":requestID", use: cancelRequest)
        requests.put("unaccept", ":requestID", use: unacceptRequest)
        requests.put("markCompleted", ":requestID", use: markRequestCompleted)

        // to delete a request
        passwordProtected.delete(":requestID", use: deleteRequest)

    }
    
    /** 
        Function to fetch all requests

        GET request /requests route
    */ 
    func index(req: Request) throws -> EventLoopFuture<[USIVRequest]> {
        return USIVRequest.query(on: req.db).all()
    }
    
    
    /** 
        Function to create a request

        POST request /requests route
    */ 
    func create(req: Request) throws -> EventLoopFuture<USIVRequest> {
        // Fetch the authenticated user
        let user = try req.auth.require(User.self)
        
        // Decode the request content
        let request = try req.content.decode(USIVRequest.Create.self)
        
        let requestModel = USIVRequest(
            hospital: request.hospital,
            roomNumber: request.roomNumber,
            callBackNumber: request.callBackNumber,
            notes: request.notes,
            status: 0, 
            userPosted: user.id!
        )
        
        // Save the request to the database
        return requestModel.save(on: req.db).map { requestModel }
    }

    /** 
        Function to fetch requests with status 0 (available)

        GET request /requests/available route
    */ 
    func availableRequests(req: Request) throws -> EventLoopFuture<[USIVRequest]> {
        return USIVRequest.query(on: req.db)
            .filter(\.$status == 0) // Filter requests by status 0 (available)
            .all()
    }

    /** 
        Function to fetch requests posted by the logged-in user

        GET request /requests/userPosted route
    */ 
    func requestsByUserPosted(req: Request) throws -> EventLoopFuture<[USIVRequest]> {
        // Fetch the authenticated user
        guard let userID = try req.auth.require(User.self).id else {
            throw Abort(.unauthorized)
        }
        
        return USIVRequest.query(on: req.db)
            .filter(\.$userPosted == userID)
            .all()
    }

    /** 
        Function to fetch requests accepted by the logged-in user with status 1 (accepted)

        GET request /requests/userAccepted route
    */ 
    func requestsByUserAccepted(req: Request) throws -> EventLoopFuture<[USIVRequest]> {
        // Fetch the authenticated user
        guard let userID = try req.auth.require(User.self).id else {
            throw Abort(.unauthorized)
        }
        
        return USIVRequest.query(on: req.db)
            .filter(\.$userAccepted == userID)
            .filter(\.$status == 1)
            .all()
    }

    /**
        Function to accept a request

        PUT request /requests/accept/:requestID 
    */
    func acceptRequest(req: Request) throws -> EventLoopFuture<USIVRequest> {
        // Fetch the authenticated user
        let user = try req.auth.require(User.self)
        
        // Get the request ID from the URL parameters
        guard let requestID = req.parameters.get("requestID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        // Fetch the request from the database
        return USIVRequest.find(requestID, on: req.db).unwrap(or: Abort(.notFound)).flatMap { request in
            // Update the request properties
            request.status = 1
            request.userAccepted = user.id!
            
            // Save the modified request to the database
            return request.save(on: req.db).map { request }
        }
    }

    /**
        Function to cancel a request 

        PUT request /requests/cancel/:requestID 
    */
    func cancelRequest(req: Request) throws -> EventLoopFuture<USIVRequest> {
        // Get the request ID from the URL parameters
        guard let requestID = req.parameters.get("requestID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        // Fetch the request from the database
        return USIVRequest.find(requestID, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { request in
                
                // Modify the request status
                request.status = 2
                
                // Save the modified request to the database
                return request.save(on: req.db)
                    .map { request }
            }
    }


    /**
        Function to unaccept a request

        PUT request /requests/unaccept/:requestID 
    */
    func unacceptRequest(req: Request) throws -> EventLoopFuture<USIVRequest> {
        // Get the request ID from the URL parameters
        guard let requestID = req.parameters.get("requestID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        // Fetch the request from the database
        return USIVRequest.find(requestID, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { request in
                // Modify the request properties
                request.status = 0
                request.userAccepted = nil
                
                // Save the modified request to the database
                return request.save(on: req.db)
                    .map { request }
            }
    }

    /**
        Function to mark a request as completed

        PUT request /requests/markCompleted/:requestID 
    */
    func markRequestCompleted(req: Request) throws -> EventLoopFuture<USIVRequest> {
        // Get the request ID from the URL parameters
        guard let requestID = req.parameters.get("requestID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        // Fetch the request from the database
        return USIVRequest.find(requestID, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { request in
                // Modify the request status
                request.status = 3
                
                // Save the modified request to the database
                return request.save(on: req.db)
                    .map { request }
            }
    }

    /**
        Function to delete a request

        DELETE request /requests/:requestID
    */
    func deleteRequest(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        // Get the request ID from the URL parameters
        guard let requestID = req.parameters.get("requestID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        // Find the request in the database
        return USIVRequest.find(requestID, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { request in
                // Delete the request from the database
                return request.delete(on: req.db)
                    .transform(to: .noContent)
            }
    }   


}