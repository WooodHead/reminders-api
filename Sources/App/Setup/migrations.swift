//
//  migrations.swift
//  App
//
//  Created by idelfonso Gutierrez on 1/7/20.
//

import Foundation
import Vapor
import FluentPostgreSQL
import AppModels

func configureMigrations(config: inout MigrationConfig) {
    config.add(model: Todo.self, database: .psql)
    config.add(model: User.self, database: .psql)
}

