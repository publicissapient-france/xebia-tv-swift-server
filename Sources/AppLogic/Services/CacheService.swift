import Foundation
import Vapor
import VaporRedis

public protocol CacheService {
    func load(for key: String) throws -> Node?
    func save(node: Node, with key: String, expiration: TimeInterval) throws
}

public class RedisService : CacheService {
    private let drop: Droplet
    
    enum Error : Swift.Error {
        case unsupportedCache
    }
    
    public init(drop: Droplet) throws {
        try drop.addProvider(VaporRedis.Provider(config: drop.config))
        self.drop = drop
    }
    
    public func save(node: Node, with key: String, expiration: TimeInterval) throws {
        try drop.cache.set(key, node)
        if let redisCache = drop.cache as? RedisCache {
            try redisCache.redbird.command("EXPIRE", params: [key, "\(Int(expiration))"])
        }
    }
    
    public func load(for key: String) throws -> Node? {
        return try drop.cache.get(key)
    }
    
    public func ttl(for key: String) throws -> TimeInterval {
        guard let redisCache = drop.cache as? RedisCache else {
            throw Error.unsupportedCache
        }
        let response = try redisCache.redbird.command("TTL", params: [key])
        return try TimeInterval(response.toInt())
    }
}
