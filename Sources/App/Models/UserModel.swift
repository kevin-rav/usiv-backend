//
//  File.swift
//  
//
//  Created by 陈颢文 on 2/7/24.
//

import Foundation
import Fluent
import Vapor

//User model
/// Represents a user in the application.
final class User: Model, Content {
    static let schema: String = "User"
    
    @ID var id: UUID?
    
    @Field(key: "userName") var userName: String
    @Field(key: "password") var password: String

    @Field(key: "role") var role: Int
    
    /// Initializes a new instance of the User class.
    init() { }

    /// Initializes a new instance of the User class with the specified parameters.
    /// - Parameters:
    ///   - id: The unique identifier of the user.
    ///   - userName: The username of the user.
    ///   - password: The password of the user.
    init(id: UUID? = nil, userName: String, password: String, role: Int) {
        self.id = id
        self.userName = userName
        self.password = password
        self.role = role
    }
}

/// Represents the expected data for a POST request to create a user.
extension User {
    struct Create: Content {
        /// The username of the user.
        var userName: String
        /// The password of the user.
        var password: String
        /// The confirmed password of the user.
        var confirmPassword: String
        /// The role of the user
        var role: Int
    }
}

//Registration data validation for user
extension User.Create: Validatable {
    /// Defines the validation rules for the user registration data.
    ///
    /// - Parameters:
    ///   - validations: The `Validations` object to add the validation rules to.
    static func validations(_ validations: inout Validations) {
        validations.add("userName", as: String.self, is: !.empty) // make sure userName is not empty
        validations.add("password", as: String.self, is: .count(8...)) //make sure password is strong enough
    }
}


extension User: ModelAuthenticatable {
    /// The key path for the username property of the User model.
    static let usernameKey = \User.$userName
    
    /// The key path for the password hash property of the User model.
    static let passwordHashKey = \User.$password

    /// Verifies if the provided password matches the stored password hash.
    /// - Parameters:
    ///   - password: The password to verify.
    /// - Returns: A boolean value indicating whether the password is verified or not.
    /// - Throws: An error if there is an issue with the verification process.
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.password)
    }
}



