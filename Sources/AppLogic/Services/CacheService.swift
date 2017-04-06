import Foundation
import Vapor
import VaporRedis

protocol CacheService {
    func load(for key: String) throws -> Node?
    func save(node: Node, with key: String, expiration: String) throws
}

class RedisService : CacheService {
    private let drop: Droplet
    
    enum Error : Swift.Error {
        case unsupportedCache
    }
    
    init(drop: Droplet) {
        self.drop = drop
    }
    
    func save(node: Node, with key: String, expiration: String) throws {
        try drop.cache.set(key, node)
        if let redisCache = drop.cache as? RedisCache {
            try redisCache.redbird.command("EXPIRE", params: [key, expiration])
        }
    }
    
    func load(for key: String) throws -> Node? {
        return try drop.cache.get(key)
    }
    
    func ttl(for key: String) throws -> Int {
        guard let redisCache = drop.cache as? RedisCache else {
            throw Error.unsupportedCache
        }
        let response = try redisCache.redbird.command("TTL", params: [key])
        return try response.toInt()
    }
}
