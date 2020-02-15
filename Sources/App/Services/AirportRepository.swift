//
//  AirportRepository.swift
//  App
//
//  Created by Idelfonso Gutierrez on 2/14/20.
//

import Vapor
import FluentPostgreSQL
import Foundation
import AppModels

protocol AiportRepository: ServiceType {
    func find(id: String) -> Future<Airport?>
    func all() -> Future<[Airport]>
    func findUsers(forAirport airport: Airport) -> Future<[User]>
}

final class PostgreSQLAiportRepository: AiportRepository {
    static let serviceSupports: [Any.Type] = [AiportRepository.self]
    let db: PostgreSQLDatabase.ConnectionPool

    init(_ db: PostgreSQLDatabase.ConnectionPool) {
        self.db = db
    }
    
    func find(id: String) -> Future<Airport?> {
        db.withConnection { (conn)  in
            return Airport.find(id, on: conn)
        }
    }
    
    func all() -> Future<[Airport]> {
        db.withConnection { (conn)  in
            return Airport.query(on: conn).all()
        }
    }
    
    func findUsers(forAirport airport: Airport) -> Future<[User]> {
        db.withConnection { (conn)  in
            return airport.users.query(on: conn).all()
        }
    }

    static func makeService(for worker: Container) throws -> Self {
        return .init(try worker.connectionPool(to: .psql))
    }
}
