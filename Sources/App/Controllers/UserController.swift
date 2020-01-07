//
//  UserController.swift
//  App
//
//  Created by idelfonso Gutierrez on 1/1/20.
//

import Foundation
import Vapor
import Fluent
import AppModels

final class UserController: RouteCollection {
    private let userRepository: UserRepository
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func boot(router: Router) throws {
        let userRoutes = router.grouped("api","users")
        userRoutes.get(use: getAllHandler)
        userRoutes.get(User.parameter, use: getAllHandler)
        userRoutes.post(User.self, use: createHandler)
    }
    
    /// Saves user to the database
    /// - Parameters:
    ///   - req: Request.self
    ///   - user: root level User.Type JSON
    public func createHandler(_ req: Request, user: User) throws -> Future<User> {
        return userRepository.save(user: user)
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[User]> {
        return userRepository.all()
    }
    
    func getHandler(_ req: Request) throws -> Future<User> {
        return try req.parameters.next(User.self)
    }
}
