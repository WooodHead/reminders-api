import Vapor
import AppModels
import Fluent

/// Controls basic CRUD operations on `Todo`s.
final class TodoController: RouteCollection {
    // thread-safe architecture
    private let todoRespositroy: TodoRespositroy
    
    private let CategoriasKey = "categorias"
    
    init(todoRespositroy: TodoRespositroy) {
        self.todoRespositroy = todoRespositroy
    }
    
    func boot(router: Router) throws {
        let todoRoutes = router.grouped("api", "todo")
        todoRoutes.get("all", use: indexHandler)
        todoRoutes.get(use: todoByTitleOrIDHandler)
        todoRoutes.get(use: todoByIdQueryParamsHandler) //  1. URLQueryParams ≈ req.query[Type.self, at: :key]
        todoRoutes.post(Todo.self, use: createHandler) //3. decodes the Todo object for the handler
        todoRoutes.put(Todo.parameter, use: updateTodoHandler)
        todoRoutes.delete(Todo.parameter, use: deleteHandler)
        
        // User association
        todoRoutes.get(Todo.parameter, "user", use: getUserHandler) // v1/api/todo/type_id/user | type_id ≈ Todo.parametes
        
        // Categories association
        todoRoutes.post(Todo.parameter, CategoriasKey, Categoria.parameter, use: addCategoriasHandler)
        todoRoutes.get(Todo.parameter, CategoriasKey, use: getCategoriasHandler)
        
        // you dont need to specifiy the parameters type in the PathComponents for the func parameter
    }
    
    // MARK: -
    ///
    /// - Parameter req: Request
    func todoByTitleOrIDHandler(_ req: Request) throws -> Future<[Todo]> {
        return try todoRespositroy.findByParams(query: req.query)
    }
    
    ///
    /// - Parameter req:
    func todoByIdQueryParamsHandler(_ req: Request) throws -> Future<Todo> {
        guard let searchById = req.query[Int.self, at: "id"] else {
            throw Abort(.badRequest)
        }
        
        return todoRespositroy.find(id: searchById).unwrap(or: Abort(.ok))
    }
    
    /// Search the database for a Todo object
    /// - Parameter id: Int pass in the path
    func todoByIdPathHandler(_ req: Request) throws -> Future<Todo?> {
        let id = try req.parameters.next(Int.self)
        return todoRespositroy.find(id: id)
    }
    
    /// Updates the decoded Todo in the database
    /// - Parameter req: Request
    func updateTodoHandler(_ req: Request) throws -> Future<Todo> {
        return try flatMap(to: Todo.self,
                           req.parameters.next(Todo.self), //find the Todo in the DB??
                           req.content.decode(Todo.self)) { (todo, updatedTodo) in // JSONDecoder
                            return self.todoRespositroy.update(todo, withValue: updatedTodo)
        }
    }
    
    ///
    /// - Parameter req:
    func getUserHandler(_ req: Request) throws -> Future<User> {
        return try req.parameters.next(Todo.self).flatMap(to: User.self, { (todo) in
            return self.todoRespositroy.user(forTodo: todo)
        })
    }
    
    /// Returns a list of all `Todo`s.
    func indexHandler(_ req: Request) throws -> Future<[Todo]> {
        return todoRespositroy.all()
    }

    /// Saves a decoded `Todo` to the database.
    func createHandler(_ req: Request, content: Todo) throws -> Future<Todo> {
        return todoRespositroy.save(content)
    }

    /// Deletes a parameterized `Todo`.
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        let id = try req.parameters.next(Int.self)
        return todoRespositroy.delete(id)
    }
    
    /// Set a reminder's category
    func addCategoriasHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try flatMap(to: HTTPStatus.self,
                           req.parameters.next(Todo.self),
                           req.parameters.next(Categoria.self), { (todo, categoria) in
                            return todo.categorias.attach(categoria, on: req).transform(to: .created)
        })
    }
    
    func getCategoriasHandler(_ req: Request) throws -> Future<[Categoria]> {
        return try req.parameters.next(Todo.self).flatMap(to: [Categoria].self, { (todo) in
            try todo.categorias.query(on: req).all()
        })
    }
}
