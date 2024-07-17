import Vapor
import Logging
import Zenea
import ZeneaCache
import ZeneaFiles

@main
final class Server: Sendable {
    static func main() async throws {
        var env = try Environment.detect()
        try LoggingSystem.bootstrap(from: &env)
        
        let app = Application(env)
        defer { app.shutdown() }
        
        do {
            app.logger.debug("initializing server")
            let server = Server(app: app)
            
            app.logger.debug("configuring server")
            try await server.configure()
            
            app.logger.debug("starting server")
            try await server.run()
        } catch {
            app.logger.report(error: error)
            throw error
        }
    }
    
    let application: Application
    let cache: BlockCache<BlockFS>
    
    init(app: Application) {
        self.application = app
        self.cache = loadSource()
    }
    
    func configure() async throws {
        switch await self.cache.updateList() {
        case .success: break
        case .failure(.unable):
            application.logger.error("unable to setup cache")
            throw Block.ListError.unable
        }
        
        application.get { req async in
            Response(status: .notFound, body: "Nothing to see here. Please go do something with your life.")
        }
        
        application.get(.catchall) { req async in
            Response(status: .notFound, body: "Nothing to see here. Please go do something with your life.")
        }
        
        application.get("blocks", use: self.getAllBlocks(_:))
        application.on(.HEAD, "block", .parameter("id"), use: self.headBlock(_:))
        application.get("block", .parameter("id"), use: self.getBlock(_:))
        application.post("block", use: self.postBlock(_:))
        
        application.http.server.configuration.port = 4096
    }
    
    func run() async throws {
        try await application.startup()
        
        application.logger.info("server is running on port \(application.http.server.configuration.port)")
        try await application.running?.onStop.get()
    }
}
