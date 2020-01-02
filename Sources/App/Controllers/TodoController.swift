import Vapor
import AppModels
import Fluent

/// Controls basic CRUD operations on `Todo`s.
final class TodoController: RouteCollection {
    func boot(router: Router) throws {
        let todoRoutes = router.grouped("api", "todo")
        // You only get to use a specific HTTPMethod once
        //todoGroup.get(use: todoSearchByTitle)
        todoRoutes.get(use: todoByIdQueryParams) //  1. URLQueryParams ≈ req.query[Type.self, at: :key]
        todoRoutes.get(Todo.parameter, use: todoByIdPath) // 2. scheme/host/path/type ≈ Todo.parametes
        todoRoutes.post(Todo.self, use: create) //3. jsonBody ≈ Todo.self
        todoRoutes.delete(use: delete)
        
//        router.get("api", "todo", use: todoByID)
//        router.get("api", "todo", use: todoSearchByTitle)
        // you dont need to specifiy the Parameters in the .get(path: "", Todo.parameter)
        // many query params???
    }
    
    func todoByIdQueryParams(_ req: Request) throws -> Future<Todo> {
        guard let searchById = req.query[Int.self, at: "id"] else {
            throw Abort(.badRequest)
        }
        return Todo.find(searchById, on: req).unwrap(or: Abort(.ok))
    }
    
    /// Search the database for a Todo object
    /// - Parameter id: Int pass in the path
    func todoByIdPath(_ req: Request) throws -> Future<Todo> {
        return try req.parameters.next(Todo.self)
    }
    
    func todoByTitleOrID(_ req: Request) throws -> Future<[Todo]> {
        // strings can be empty
        guard let searchByTitle = req.query[String.self, at: "term"], let id = req.query[Int.self, at: "id"] else {
            throw Abort(.badRequest)
        }
        
        return Todo.query(on: req).group(.or) { or in
            or.filter(\.id == id)
            or.filter(\.title == searchByTitle)
        }.all()
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
    func create(_ req: Request, todo: Todo) throws -> Future<Todo> {
        return todo.save(on: req)
    }

    /// Deletes a parameterized `Todo`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Todo.self).flatMap { todo in
            return todo.delete(on: req)
        }.transform(to: .ok)
    }
}
