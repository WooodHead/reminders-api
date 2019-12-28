import Vapor
import AppModels

/// Controls basic CRUD operations on `Todo`s.
final class TodoController {
    func boot(router: Router) throws {
        let todoGroup = router.grouped("api", "reminder")
        todoGroup.get(use: index)
        todoGroup.post(use: create)
        todoGroup.delete(use: delete)
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
    
    func batchCreate(_ reminders: [Todo], _ req: Request) throws -> Future<[Todo]> {
        var todoSaveResults: [Future<Todo>] = []
        for item in reminders {
            todoSaveResults.append(item.save(on: req))
        }
        return todoSaveResults.flatten(on: req).flatMap { (todo)  in
            return try self.index(req)
        }
    }
    

    /// Deletes a parameterized `Todo`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Todo.self).flatMap { todo in
            return todo.delete(on: req)
        }.transform(to: .ok)
    }
}
