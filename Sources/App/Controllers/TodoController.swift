import Vapor
import AppModels
import Fluent

/// Controls basic CRUD operations on `Todo`s.
final class TodoController: RouteCollection {
    // thread-safe architecture
    private let todoRespositroy: TodoRespositroy
    init(todoRespositroy: TodoRespositroy) {
        self.todoRespositroy = todoRespositroy
    }
    
    func boot(router: Router) throws {
        let todoRoutes = router.grouped("api", "todo")
        todoRoutes.get(use: todoByTitleOrID)
        todoRoutes.get(use: todoByIdQueryParams) //  1. URLQueryParams ≈ req.query[Type.self, at: :key]
//        todoRoutes.get(Todo.parameter, use: todoByIdPath) // 2. scheme/host/path/type_id ≈ Todo.parametes
        todoRoutes.post(Todo.self, use: create) //3. decodes the Todo object for the handler
        todoRoutes.put(Todo.parameter, use: updateTodo)
        todoRoutes.delete(Todo.self, use: delete)
        // you dont need to specifiy the Parameters in the .get(path: "", Todo.parameter)
    }
    
    func todoByIdQueryParams(_ req: Request) throws -> Future<Todo> {
        guard let searchById = req.query[Int.self, at: "id"] else {
            throw Abort(.badRequest)
        }
        
        return todoRespositroy.find(id: searchById).unwrap(or: Abort(.ok))
    }
    
    //todoRoutes.get(Todo.parameter, use: todoByIdPath)
    /// Search the database for a Todo object
    /// - Parameter id: Int pass in the path
    func todoByIdPath(_ req: Request) throws -> Future<Todo?> {
        let id = try req.parameters.next(Int.self)
        return todoRespositroy.find(id: id)
    }
    
    func todoByTitleOrID(_ req: Request) throws -> Future<[Todo]> {
        return try todoRespositroy.findByParams(query: req.query)
    }
    
    func updateTodo(_ req: Request) throws -> Future<Todo> {
        return try flatMap(to: Todo.self,
                           req.parameters.next(Todo.self), //find the Todo in the DB??
                           req.content.decode(Todo.self)) { (todo, updatedTodo) in // JSONDecoder
                            
                            todo.title = updatedTodo.title
                            todo.userID = updatedTodo.userID
                            return todo.save(on: req)
        }
    }
    
    /// Returns a list of all `Todo`s.
    func index(_ req: Request) throws -> Future<[Todo]> {
        return todoRespositroy.all()
    }

    /// Saves a decoded `Todo` to the database.
    func create(_ req: Request, content: Todo) throws -> Future<Todo> {
        return todoRespositroy.save(content)
    }

    /// Deletes a parameterized `Todo`.
    func delete(_ req: Request, content: Todo) throws -> Future<HTTPStatus> {
        return todoRespositroy.delete(content)
    }
}
