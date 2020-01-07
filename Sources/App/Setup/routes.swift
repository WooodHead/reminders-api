import Vapor
import AppModels

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    let todoController = TodoController()
    try router.register(collection: todoController)
    
    let userController = UserController()
    try router.register(collection: userController)
}

//router.post(InfoData.self, at: "info") { (request, data) -> InfoResponse in
//    return InfoResponse(request: data)
//}

