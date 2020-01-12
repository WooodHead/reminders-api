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
    
    /// Registers a group of routers following ["api", "users"] path
    /// - Parameter router:
    func boot(router: Router) throws {
        let userRoutes = router.grouped("api","users")
        userRoutes.get(use: getAllHandler)
        userRoutes.get(User.parameter, use: getAllHandler)
        userRoutes.post(User.self, use: createHandler)
        userRoutes.get(User.parameter, "todos", use: getTodosHandler)
    }
    
    /// Saves user to the database
    /// - Parameters:
    ///   - req: Request.self
    ///   - user: root level User.Type JSON
    public func createHandler(_ req: Request, user: User) throws -> Future<User> {
        return userRepository.save(user: user)
    }
    
    /// Fetch all the users in the database
    /// - Parameter req: container
    func getAllHandler(_ req: Request) throws -> Future<[User]> {
        return userRepository.all()
    }
    
    /// Fetch the specify user from the database
    /// - Parameter req: container
    func getHandler(_ req: Request) throws -> Future<User> {
        return try req.parameters.next(User.self)
    }
    
    func getTodosHandler(_ req: Request) throws -> Future<[Todo]> {
        return try req.parameters.next(User.self).flatMap(to: [Todo].self) { (user) in
            self.userRepository.findTodos(forUser: user)
        }
    }
}
