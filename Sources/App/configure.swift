import Vapor
import zenea
import zenea_fs

func configure(_ app: Application) async throws {
    let blocks = await loadSources(client: app.http.client.shared)
    await blocks.updateList()
    
    let system = BlockSystem(cache: blocks)
    
    app.get { req async in
        return Response(status: .notFound, body: "Nothing to see here. Please go do something with your life.")
    }
    
    app.get(.catchall) { req async in
        return Response(status: .notFound, body: "Nothing to see here. Please go do something with your life.")
    }
    
    app.get("blocks", use: system.getBlocks(_:))
    app.on(.HEAD, "blocks", .parameter("id"), use: system.headBlock(_:))
    app.get("block", .parameter("id"), use: system.getBlock(_:))
    app.post("block", use: system.postBlock(_:))
    
    app.http.server.configuration.port = 4096
}
