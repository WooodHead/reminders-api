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
    func user(forTodo todo: Todo) -> Future<User>
    func find(title: String) -> Future<Todo?>
    func findCount() -> Future<Int>
    func save(_ content: Todo) -> Future<Todo>
    func findByParams(query: QueryContainer) throws -> Future<[Todo]>
    func delete(_ id: Int) -> EventLoopFuture<HTTPStatus>
    func update(_ todo: Todo, withValue newValue: Todo) -> Future<Todo>
    func setCategory(_ todoLoop: Future<Todo>, _ categoriaLoop: Future<Categoria>) throws -> Future<HTTPStatus>
    func getCategorias(for todoLoop: Future<Todo>) throws -> Future<[Categoria]>
}

final class PostgreSQLTodoRepository: TodoRespositroy {
    
    let db: PostgreSQLDatabase.ConnectionPool
    static let serviceSupports: [Any.Type] = [UserRepository.self]
     
    init(_ db: PostgreSQLDatabase.ConnectionPool) {
        self.db = db
    }
    
    // MARK: ServiceType Protocol
    static func makeService(for container: Container) throws -> Self {
        return .init(try container.connectionPool(to: .psql))
    }
    
    // MARK: TodoRepository protocol
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
    
    func findByParams(query: QueryContainer) throws -> Future<[Todo]> {
        guard let searchByTitle = query[String.self, at: "term"], let id = query[Int.self, at: "id"] else {
            throw Abort(.badRequest)
        }
        
        return db.withConnection { (conn) in
            return Todo.query(on: conn).group(.or) { or in
                or.filter(\.id == id)
                or.filter(\.title == searchByTitle)
            }.all()
        }
    }
    
    func save(_ content: Todo) -> Future<Todo> {
        return db.withConnection { (conn) in
            return content.save(on: conn)
        }
    }
    
    func update(_ todo: Todo, withValue newValue: Todo) -> EventLoopFuture<Todo> {
        return db.withConnection { (conn) in
            todo.title = newValue.title
            todo.userID = newValue.userID
            return todo.save(on: conn)
        }
    }
    
    func user(forTodo todo: Todo) -> Future<User> {
        return db.withConnection { (conn) in
            return todo.user.get(on: conn)
        }
    }
    
    func delete(_ id: Int) -> EventLoopFuture<HTTPStatus> {
        return db.withConnection { (conn) in
            Todo.find(id, on: conn).flatMap { (todo) in
                guard let todo = todo else {
                    return conn.future(.notFound)
                }
                
                return todo.delete(on: conn).transform(to: .ok)
            }
        }
    }
    
    func setCategory(_ todoLoop: EventLoopFuture<Todo>, _ categoriaLoop: EventLoopFuture<Categoria>) throws -> EventLoopFuture<HTTPStatus> {
        return db.withConnection { (conn) in
            return flatMap(to: HTTPStatus.self, todoLoop, categoriaLoop, { (todo, categoria) in
                    return todo.categorias.attach(categoria, on: conn).transform(to: .created)
            })
        }
    }
    
    func getCategorias(for todoLoop: EventLoopFuture<Todo>) throws -> EventLoopFuture<[Categoria]> {
        return db.withConnection { (conn) in
            return todoLoop.flatMap(to: [Categoria].self, { (todo) in
                try todo.categorias.query(on: conn).all()
            })
        }
    }
    
}
