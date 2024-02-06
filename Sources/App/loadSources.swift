import Foundation
import NIOFileSystem
import Vapor
import zenea
import zenea_fs
import zenea_http

func loadSources(client: HTTPClient) async -> BlocksCache {
    let results = BlocksCache(stores: [])
    
    let zeneaDir = FilePath(NSString("~/.zenea").expandingTildeInPath as String)
    let configDir = zeneaDir.appending("config")
    let sourcesFile = configDir.appending("sources.json")
    
    do {
        let handle = try await FileSystem.shared.openFile(forReadingAt: sourcesFile)
        defer { Task { try? await handle.close() } }
        
        let buffer = try await handle.readToEnd(maximumSizeAllowed: .megabytes(42))
        let sources = try JSONDecoder().decode([Source].self, from: buffer)
        
        for source in sources {
            switch source {
            case .file(path: let path):
                results.stores.append(BlockFS(path))
            case .http(scheme: let scheme, domain: let domain, port: let port):
                results.stores.append(ZeneaHTTPClient(scheme: scheme, address: domain, port: port, client: client))
            }
        }
        
        return results
    } catch {
        return results
    }
}

enum Source: Codable {
    case file(path: String)
    case http(scheme: ZeneaHTTPClient.Scheme, domain: String, port: Int)
}
