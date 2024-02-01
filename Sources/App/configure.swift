import Vapor
import zenea
import zenea_fs

func configure(_ app: Application) throws {
    let blocks = BlockFS(NSString("~/.zenea").expandingTildeInPath as String)
    
    app.get { req async in
        return Response(status: .notFound, body: "Nothing to see here. Please go do something with your life.")
    }
    
    app.get(.catchall) { req async in
        return Response(status: .notFound, body: "Nothing to see here. Please go do something with your life.")
    }

    app.get("hello") { req async in
        "Hello, world!"
    }
    
    app.get("block", .parameter("id")) { req async in
        guard let idString = req.parameters.get("id") else {
            return Response(status: .noContent, body: "may i see your id please")
        }
        
        guard let blockID = Block.ID(parsing: idString) else {
            return Response(status: .badRequest, body: "what the hell is that supposed to be")
        }
        
        switch await blocks.fetchBlock(id: blockID) {
        case .success(let block): return Response(body: Response.Body(data: block.content))
        case .failure(let error):
            switch error {
            case .notFound: return Response(status: .notFound, body: "nope, haven't seen it")
            case .invalidContent: return Response(status: .internalServerError, body: "idfk")
            case .unable: return Response(status: .internalServerError, body: "something went wrong")
            }
        }
    }
    
    app.post("block") { req async in
        do {
            guard var contentBuffer = try await req.body.collect(max: 2<<16).get() else {
                return Response(status: .badRequest, body: "come on give me something")
            }
            
            guard let data = contentBuffer.readData(length: contentBuffer.readableBytes, byteTransferStrategy: .noCopy) else {
                return Response(status: .badRequest, body: "come on give me something")
            }
            
            switch await blocks.putBlock(content: data) {
            case .success(let blockID):
                guard let data = blockID.description.data(using: .utf8) else {
                    return Response(status: .internalServerError, body: "idfk")
                }
                return Response(status: .ok, body: .init(data: data))
            case .failure(let error):
                switch error {
                case .exists: return Response(status: .notFound, body: "we already have one, thanks")
                case .unavailable: return Response(status: .badGateway, body: "not my fault")
                case .notPermitted: return Response(status: .forbidden, body: "you shall not pass")
                case .unable: return Response(status: .internalServerError, body: "idk didn't work")
                }
            }
        } catch {
            return Response(status: .internalServerError, body: "come on give me something")
        }
    }
    
    app.get("blocks") { _ async in
        switch await blocks.listBlocks() {
        case .success(let blocks):
            let body = blocks.map { $0.description }.joined(separator: ",")
            guard let data = body.data(using: .utf8) else { return Response(status: .internalServerError, body: "i hate unicode") }
            
            return Response(status: .ok, body: Response.Body(data: data))
        case .failure(let error):
            switch error {
            case .unable: return Response(status: .internalServerError, body: "something went wrong")
            }
        }
    }
    
    app.http.server.configuration.port = 4096
}
