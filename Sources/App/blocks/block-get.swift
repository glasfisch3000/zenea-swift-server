import Vapor

import zenea

extension BlockSystem {
    @Sendable func getBlock(_ request: Request) async -> Response {
        guard let idString = request.parameters.get("id") else {
            return Response(status: .badRequest, body: "may i see your id please")
        }
        
        guard let blockID = Block.ID(parsing: idString) else {
            return Response(status: .badRequest, body: "what the hell is that supposed to be")
        }
        
        switch await self.cache.fetchBlock(id: blockID) {
        case .success(let block):
            return Response(status: .ok, body: Response.Body(data: block.content))
        case .failure(.notFound):
            return Response(status: .notFound, body: "nope, haven't seen it")
        case .failure(.invalidContent):
            return Response(status: .internalServerError, body: "idfk")
        case .failure(.unable):
            return Response(status: .internalServerError, body: "something went wrong")
        }
    }
}
