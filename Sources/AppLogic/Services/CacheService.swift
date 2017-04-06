import Foundation
import Vapor
import VaporRedis

protocol CacheService {
    func save(node: Node, with key: String) throws
}

class RedisService : CacheService {
    private let drop: Droplet
    
    init(drop: Droplet) {
        self.drop = drop
    }
    
    private var cacheExpiration: String {
        return drop.config["app", "youtube", "cacheExpiration"]?.string ?? "0"
    }
    
    func save(node: Node, with key: String) throws {
        try drop.cache.set(key, node)
        if let redisCache = drop.cache as? RedisCache {
            try redisCache.redbird.command("EXPIRE", params: [key, cacheExpiration])
        }
    }
}
