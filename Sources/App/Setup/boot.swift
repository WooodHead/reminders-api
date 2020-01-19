import Vapor

/// Called after your application has initialized.
public func boot(_ app: Application) throws {
    // Application as a container to create services required for booting your app
    let client = try app.make(Client.self)
    let res = try client.get("http://vapor.codes").wait()
}
