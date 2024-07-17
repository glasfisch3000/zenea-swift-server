import Vapor
import Zenea

extension Server {
    @Sendable func headBlock(_ request: Request) async -> Response {
        guard let idString = request.parameters.get("id") else {
            return Response(status: .badRequest, body: "may i see your id please")
        }
        
        guard let blockID = Block.ID(parsing: idString) else {
            return Response(status: .badRequest, body: "what the hell is that supposed to be")
        }
        
        switch await self.cache.checkBlock(id: blockID) {
        case .success(true):
            return Response(status: .ok, body: .empty)
        case .success(false):
            return Response(status: .notFound, body: .empty)
        case .failure(.unable):
            return Response(status: .internalServerError, body: "something went wrong")
        }
    }
}
