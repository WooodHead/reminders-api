//
//  TodoRepository.swift
//  App
//
//  Created by Idelfonso Gutierrez on 1/7/20.
//

import Vapor
import FluentPostgreSQL
import Foundation
import AppModels

protocol TodoRespositroy: ServiceType {
    func find(id: Int) -> Future<Todo?>
    func all() -> Future<[Todo]>
    func find(title: String) -> Future<Todo?>
    func findCount() -> Future<Int>
    func save(todo: Todo) -> Future<Todo>
}

final class PostgreSQLTodoRepository: TodoRespositroy {
    let db: PostgreSQLDatabase.ConnectionPool
    static let serviceSupports: [Any.Type] = [UserRepository.self]
     
    init(_ db: PostgreSQLDatabase.ConnectionPool) {
        self.db = db
    }
    
    func find(id: Int) -> EventLoopFuture<Todo?> {
        return db.withConnection { (conn) in
            return Todo.find(id, on: conn)
        }
    }
    
    func all() -> EventLoopFuture<[Todo]> {
        return db.withConnection { (conn) in
            return Todo.query(on: conn).all()
        }
    }
    
    func find(title: String) -> EventLoopFuture<Todo?> {
        return db.withConnection { (conn) in
            return Todo.query(on: conn).filter(\.title == title).first()
        }
    }
    
    func findCount() -> EventLoopFuture<Int> {
        return db.withConnection { (conn) in
            return Todo.query(on: conn).count()
        }
    }
    
    func save(todo: Todo) -> EventLoopFuture<Todo> {
        return db.withConnection { (conn) in
            return todo.save(on: conn)
        }
    }
    
    static func makeService(for container: Container) throws -> Self {
        return .init(try container.connectionPool(to: .psql))
    }
    
}
