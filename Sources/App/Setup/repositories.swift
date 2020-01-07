//
//  repositories.swift
//  App
//
//  Created by Idelfonso Gutierrez on 1/6/20.
//

import Foundation
import Vapor

public func setupRepositories(services: inout Services, config: inout Config) {
    services.register(PostgreSQLUserRepository.self)
    services.register(PostgreSQLTodoRepository.self)
    preferDatabaseRepositories(config: &config)
}

private func preferDatabaseRepositories(config: inout Config) {
    config.prefer(PostgreSQLUserRepository.self, for: UserRepository.self)
    config.prefer(PostgreSQLTodoRepository.self, for: TodoRespositroy.self)
}
