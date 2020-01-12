//
//  repositories.swift
//  App
//
//  Created by Idelfonso Gutierrez on 1/6/20.
//

import Vapor
import FluentPostgreSQL
import Foundation
import AppModels

protocol UserRepository: ServiceType {
    func find(id: UUID) -> Future<User?>
    func all() -> Future<[User]>
    func find(username: String) -> Future<User?>
    func findCount(username: String) -> Future<Int>
    func save(user: User) -> Future<User>
    func findTodos(forUser user: User) -> Future<[Todo]>
}

final class PostgreSQLUserRepository: UserRepository {
    let db: PostgreSQLDatabase.ConnectionPool

    init(_ db: PostgreSQLDatabase.ConnectionPool) {
        self.db = db
    }

    func find(id: UUID) -> EventLoopFuture<User?> {
        return db.withConnection { conn in
            return User.find(id, on: conn)
        }
    }

    func all() -> EventLoopFuture<[User]> {
        return db.withConnection { conn in
            return User.query(on: conn).all()
        }
    }

    func find(username: String) -> EventLoopFuture<User?> {
        return db.withConnection { conn in
            return User.query(on: conn).filter(\.username == username).first()
        }
    }

    func findCount(username: String) -> EventLoopFuture<Int> {
        return db.withConnection { conn in
            return User.query(on: conn).filter(\.username == username).count()
        }
    }

    func save(user: User) -> EventLoopFuture<User> {
        return db.withConnection { conn in
            return user.save(on: conn)
        }
    }
    
    func findTodos(forUser user: User) -> Future<[Todo]> {
        return db.withConnection { (conn) in
            try user.todos.query(on: conn).all()
        }
    }
}

//MARK: - ServiceType conformance
extension PostgreSQLUserRepository {
    static let serviceSupports: [Any.Type] = [UserRepository.self]

    static func makeService(for worker: Container) throws -> Self {
        return .init(try worker.connectionPool(to: .psql))
    }
}

extension Database {
    public typealias ConnectionPool = DatabaseConnectionPool<ConfiguredDatabase<Self>>
}
