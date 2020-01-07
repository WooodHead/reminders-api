import FluentSQLite
import FluentPostgreSQL
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(FluentSQLiteProvider())
    try services.register(FluentPostgreSQLProvider())
    
    // Registers Data Sources
    setupRepositories(services: &services, config: &config)
    
    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)
       
    // Register the configured psql database to the database config.
    var databasesConfig = DatabasesConfig()
    try configurePSQLDatabase(config: &databasesConfig)
    try configureSQLiteDatabase(config: &databasesConfig)
    services.register(databasesConfig)
    
    // Configure migrations
    var migrations = MigrationConfig()
    configureMigrations(config: &migrations)
    services.register(migrations)
}
