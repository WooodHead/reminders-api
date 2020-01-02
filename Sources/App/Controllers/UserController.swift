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
    func boot(router: Router) throws {
        let userRoutes = router.grouped("api","users")
        userRoutes.get(use: getAllHandler)
        userRoutes.get(User.parameter, use: getAllHandler)
        userRoutes.post(User.self, use: createHandler)
    }
    
    func createHandler(_ req: Request, user: User) throws -> Future<User> {
        return user.save(on: req)
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[User]> {
        return User.query(on: req).all()
    }
    
    func getHandler(_ req: Request) throws -> Future<User> {
        return try req.parameters.next(User.self) // I dont thin this queries the db
    }
}
