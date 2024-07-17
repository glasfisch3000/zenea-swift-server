import Vapor

extension Server {
    @Sendable func postBlock(_ request: Request) async -> Response {
        do {
            guard var contentBuffer = try await request.body.collect(max: 1<<16).get() else {
                return Response(status: .badRequest, body: "come on give me something")
            }
            
            guard let data = contentBuffer.readData(length: contentBuffer.readableBytes, byteTransferStrategy: .noCopy) else {
                return Response(status: .badRequest, body: "come on give me something")
            }
            
            switch await self.cache.putBlock(content: data) {
            case .success(let block):
                guard let data = block.id.description.data(using: .utf8) else {
                    return Response(status: .internalServerError, body: "idfk")
                }
                return Response(status: .ok, body: .init(data: data))
            case .failure(.exists):
                return Response(status: .notFound, body: "we already have one, thanks")
            case .failure(.unavailable):
                return Response(status: .badGateway, body: "not my fault")
            case .failure(.notPermitted):
                return Response(status: .forbidden, body: "you shall not pass")
            case .failure(.unable):
                return Response(status: .internalServerError, body: "idk didn't work")
            case .failure(.overflow):
                return Response(status: .badRequest, body: "overflow")
            }
        } catch {
            return Response(status: .internalServerError, body: "come on give me something")
        }
    }
}
