import Foundation
import NIOFileSystem
import ZeneaCache
import ZeneaFiles

func loadSource() -> BlockCache<BlockFS> {
    let zeneaDir = NSString("~/.zenea").expandingTildeInPath as String
    return BlockCache(source: BlockFS(zeneaDir))
}
