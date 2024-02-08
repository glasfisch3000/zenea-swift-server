import Foundation
import zenea

class BlocksCache: BlockStorage {
    var stores: [BlockStorage]
    
    private var list: Set<Block.ID>
    private var cache: [Block.ID: Block]
    
    init(stores: [BlockStorage]) {
        self.stores = stores
        self.list = []
        self.cache = [:]
    }
    
    func listBlocks() -> Result<Set<Block.ID>, BlockListError> {
        return .success(self.list)
    }
    
    func updateList() async {
        for store in stores {
            switch await store.listBlocks() {
            case .success(let blocks): self.list.formUnion(blocks)
            case .failure(_): break
            }
        }
    }
    
    func checkBlock(id: Block.ID) async -> Result<Bool, BlockCheckError> {
        if self.cache[id] != nil { return .success(true) }
        
        if self.list.contains(id) {
            for store in self.stores {
                guard let check = try? await store.checkBlock(id: id).get() else { continue }
                if check { return .success(true) }
            }
        }
        
        return .success(false)
    }
    
    func fetchBlock(id: Block.ID) async -> Result<Block, BlockFetchError> {
        if let block = self.cache[id] { return .success(block) }
        if stores.isEmpty { return .failure(.unable) }
        
        for store in stores {
            switch await store.fetchBlock(id: id) {
            case .success(let block):
                guard block.matchesID(id) else { return .failure(.invalidContent) }
                
                self.list.insert(block.id)
                self.cache[id] = block
                return .success(block)
            case .failure(_): break
            }
        }
        
        return .failure(.notFound)
    }
    
    func putBlock(content: Data) async -> Result<Block.ID, BlockPutError> {
        let block = Block(content: content)
        
        guard let exists = try? await self.checkBlock(id: block.id).get() else { return .failure(.unable) }
        guard !exists else { return .failure(.exists) }
        
        for store in stores {
            switch await store.putBlock(content: content) {
            case .success(_): break
            case .failure(let error): print("error uploading block \(block.id) to storage \(store): \(error)")
            }
        }
        
        self.list.insert(block.id)
        self.cache[block.id] = block
        
        return .success(block.id)
    }
}

extension BlocksCache: CustomStringConvertible {
    var description: String {
        "BlocksCache"
    }
}
