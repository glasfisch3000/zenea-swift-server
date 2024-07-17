import Foundation
import NIOFileSystem
import ZeneaCache
import ZeneaFiles

func loadSource() -> BlockCache<BlockFS> {
    let zeneaDir = FilePath(NSString("~/.zenea").expandingTildeInPath as String)
    let blocksDir = zeneaDir.appending("blocks")
    
    return BlockCache(source: BlockFS(blocksDir.string))
}
