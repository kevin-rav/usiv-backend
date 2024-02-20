import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor
import APNS
import VaporAPNS
import APNSCore

// configures your application
public func configure(_ app: Application) async throws {
    // Configure the database
    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database"
    ), as: .psql)

    // Add migrations
    app.migrations.add(CreateUSIVRequest())
    app.migrations.add(CreateUser())
    app.migrations.add(CreateChat())

    let appleECP8PrivateKey =
"""
-----BEGIN PRIVATE KEY-----
MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgiVAfd81Kks7nsZaf
cnlyNOMVFfxee7fLRidYjgldhyegCgYIKoZIzj0DAQehRANCAASrpRdm2mFrg4ur
Nofw3fMYVi2RC9ZelZWdY2HopeD5r9kwBq3iABEBiyxbseZNXMAzrmivNJR6yxHM
Er3Zo/vs
-----END PRIVATE KEY-----
"""
    
    // Run migrations
    try await app.autoMigrate().wait()

    // Configure APNS using JWT authentication.
    let apnsConfig = APNSClientConfiguration(
        authenticationMethod: .jwt(
            privateKey: try .loadFrom(string: appleECP8PrivateKey),
            keyIdentifier: "4PVY744HC8",
            teamIdentifier: "6XVXTHVKHM"
        ),
        environment: .sandbox
    )
    app.apns.containers.use(
        apnsConfig,
        eventLoopGroupProvider: .shared(app.eventLoopGroup),
        responseDecoder: JSONDecoder(),
        requestEncoder: JSONEncoder(),
        as: .default
    )

    // Register routes
    try routes(app)
}
