import Vapor
import AppModels

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req in
        return "It works!"
    }
    
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }
    
    router.get("hello", String.parameter) { (request) -> String in
        let name = try request.parameters.next(String.self)
        return "Hello \(name)"
    }
    
    router.post(InfoData.self, at: "info") { (request, data) -> InfoResponse in
        return InfoResponse(request: data)
    }
    
    let controller = TodoController()
//    router.post("api", "reminders", use: controller.batchCreate)
    // groupped
    try controller.boot(router: router)
    
//    You should use the Request or Response containers to create services for responding to requests (in route closures and controllers)
}

