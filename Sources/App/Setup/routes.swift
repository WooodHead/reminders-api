import Vapor
import AppModels

/// Register your application's routes here.
public func routes(_ router: Router, _ container: Container) throws {
    let userRepository = try container.make(UserRepository.self)
    let todoRepository = try container.make(TodoRespositroy.self)
    
    let todoController = TodoController(todoRespositroy: todoRepository)
    try router.register(collection: todoController)
    
    let userController = UserController(userRepository: userRepository)
    try router.register(collection: userController)
}

//router.post(InfoData.self, at: "info") { (request, data) -> InfoResponse in
//    return InfoResponse(request: data)
//}

