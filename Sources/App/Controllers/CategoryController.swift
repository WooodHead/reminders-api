//
//  CategoryController.swift
//  App
//
//  Created by Idelfonso Gutierrez on 1/13/20.
//

import Vapor
import AppModels
import Fluent

final class CategoryController: RouteCollection {
    func boot(router: Router) throws {
        let group = router.grouped("api", "category")
        
        group.post(Category.self, use: createHandler)
        group.get(use: getAllHandler)
        group.get(Category.parameter, use: getHandler)
    }
    

      func createHandler( _ req: Request, category: Category) throws -> Future<Category> {
        return category.save(on: req)
      }

      func getAllHandler(_ req: Request) throws -> Future<[Category]> {
        return Category.query(on: req).all()
      }

      func getHandler(_ req: Request) throws -> Future<Category> {
        return try req.parameters.next(Category.self)
      }
    
}
