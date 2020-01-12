import Vapor
import AppModels

/// Register your application's routes here.
public func routes(_ router: Router, _ container: Container) throws {
    let userRepository = try container.make(PostgreSQLUserRepository.self)
    let todoRepository = try container.make(PostgreSQLTodoRepository.self)
    
    let todoController = TodoController(todoRespositroy: todoRepository)
    try router.register(collection: todoController)
    
    let userController = UserController(userRepository: userRepository)
    try router.register(collection: userController)
}
