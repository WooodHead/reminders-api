import FluentSQLite
import Vapor
import AppModels

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // TODO: register services you might need
    
    // Register providers first
    try services.register(FluentSQLiteProvider())

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    // Configure a SQLite database
    var sqlite: SQLiteDatabase
       
       if env.isRelease {
           /// Create file-based SQLite db using $SQLITE_PATH from process env
           /// Use the static method Environment.get(_:) to fetch string values from the process environment.
           sqlite = try SQLiteDatabase(storage: .file(path: Environment.get("SQLITE_PATH")!)) //db.sqlite url??
       } else {
           /// Create an in-memory SQLite database
           sqlite = try SQLiteDatabase(storage: .memory)
       }
       services.register(sqlite)
    
    // Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: sqlite, as: .sqlite)
    services.register(databases)

    // Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Todo.self, database: .sqlite)
    services.register(migrations)
}
