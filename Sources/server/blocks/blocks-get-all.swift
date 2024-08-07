import Vapor

extension Server {
    @Sendable func getAllBlocks(_ request: Request) async -> Response {
        switch await self.cache.listBlocks() {
        case .success(let blocks):
            let body = blocks.map { $0.description }.joined(separator: ",")
            guard let data = body.data(using: .utf8) else { return Response(status: .internalServerError, body: "i hate unicode") }
            
            return Response(status: .ok, body: Response.Body(data: data))
        case .failure(.unable):
            return Response(status: .internalServerError, body: "something went wrong")
        }
    }
}
