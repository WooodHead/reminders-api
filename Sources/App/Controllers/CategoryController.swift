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
        group.post(Categoria.self, use: createHandler)
        group.get(use: getAllHandler)
        group.get(Categoria.parameter, use: getHandler)
    }
    

      func createHandler( _ req: Request, category: Categoria) throws -> Future<Categoria> {
        return category.save(on: req)
      }

      func getAllHandler(_ req: Request) throws -> Future<[Categoria]> {
        return Categoria.query(on: req).all()
      }

      func getHandler(_ req: Request) throws -> Future<Categoria> {
        return try req.parameters.next(Categoria.self)
      }
    
}
