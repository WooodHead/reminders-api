//
//  databases.swift
//  App
//
//  Created by Idelfonso Gutierrez on 1/6/20.
//

import Vapor
import FluentPostgreSQL
import FluentSQLite

public func configurePSQLDatabase(config: inout DatabasesConfig) throws {

//    guard let database = Environment.get("POSTGRES_DB"),
//        let user = Environment.get("POSTGRES_USER"),
//        let password = Environment.get("POSTGRES_PASSWORD") else {
//            throw Abort(.internalServerError)
//    }
//    
    let psqlConfig = PostgreSQLDatabaseConfig(hostname: "localhost", username: "vapor", database: "vapor", password: "password")
    let postgreSQLDatabase = PostgreSQLDatabase(config: psqlConfig)
    config.add(database: postgreSQLDatabase, as: .psql)
}


/// Configure SQLite datbase
/// - Parameter config: DatabasesConfig 
func configureSQLiteDatabase(config: inout DatabasesConfig) throws  {
    guard let path = Environment.get("SQLITE_PATH") else {
        throw Abort(.internalServerError)
    }
    let sqlite = try SQLiteDatabase(storage: .file(path: path))
    config.add(database: sqlite, as: .sqlite)
}

extension Database {
    public typealias ConnectionPool = DatabaseConnectionPool<ConfiguredDatabase<Self>>
}
