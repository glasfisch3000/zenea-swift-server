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
            case .success(let blocks): DispatchQueue.main.sync { self.list.formUnion(blocks) }
            case .failure(_): break
            }
        }
    }
    
    func fetchBlock(id: Block.ID) async -> Result<Block, BlockFetchError> {
        if let block = self.cache[id] { return .success(block) }
        if stores.isEmpty { return .failure(.unable) }
        
        for store in stores {
            switch await store.fetchBlock(id: id) {
            case .success(let block):
                guard block.matchesID(id) else { return .failure(.invalidContent) }
                
                DispatchQueue.main.sync { let _ = self.list.insert(block.id) }
                DispatchQueue.main.sync { self.cache[id] = block }
                return .success(block)
            case .failure(_): break
            }
        }
        
        return .failure(.notFound)
    }
    
    func putBlock(content: Data) async -> Result<Block.ID, BlockPutError> {
        let block = Block(content: content)
        
        if let cached = self.cache[block.id], cached.matchesID(block.id) { return .failure(.exists) }
        
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
