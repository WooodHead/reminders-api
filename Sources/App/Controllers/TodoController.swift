import Vapor
import AppModels
import Fluent

/// Controls basic CRUD operations on `Todo`s.
final class TodoController {
    func boot(router: Router) throws {
        let todoGroup = router.grouped("api", "reminder")
        todoGroup.get(use: index)
        todoGroup.post(use: create)
        todoGroup.delete(use: delete)
    }
    
    func todoByID(_ req: Request) throws -> Future<Todo> {
        guard let searchById = req.query[Int.self, at: "id"] else {
            throw Abort(.badRequest)
        }
        
        return Todo.find(searchById, on: req).unwrap(or: Abort(.ok))
    }
    
    func todoSearchByTitle(_ req: Request) throws -> Future<[Todo]> {
        guard let searchByTitle = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        
        return Todo.query(on: req).filter(\.title == searchByTitle).all()
    }
    
    func todoPUT(_ req: Request) throws -> Future<Todo> {
        return try flatMap(to: Todo.self, req.parameters.next(Todo.self), req.content.decode(Todo.self)) { (todo, updatedTodo) in
            todo.title = updatedTodo.title
            return todo.save(on: req)
        }
    }
    
    /// Returns a list of all `Todo`s.
    func index(_ req: Request) throws -> Future<[Todo]> {
        // use the request objc to create services
        return Todo.query(on: req).all()
    }

    /// Saves a decoded `Todo` to the database.
    func create(_ req: Request) throws -> Future<Todo> {
        return try req.content.decode(Todo.self).flatMap { todo in
            return todo.save(on: req).catchFlatMap { (error) -> Future<Todo> in
                return Todo(title: "lorem ipsun").save(on: req)
            }
        }
    }

    /// Deletes a parameterized `Todo`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Todo.self).flatMap { todo in
            return todo.delete(on: req)
        }.transform(to: .ok)
    }
}
