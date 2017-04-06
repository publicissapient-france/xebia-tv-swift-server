import XCTest
@testable import Vapor
import HTTP
import AppLogic

class CacheServiceTests: XCTestCase {
    
    func testExpiration() throws {
        let drop = try makeTestDroplet()
        let key = "A"
        let expiration: TimeInterval = 30
        
        let redisService = try RedisService(drop: drop)
        let node = Node(stringLiteral: "a-value")
        try redisService.save(node: node, with: key, expiration: expiration)
        
        let ttl = try redisService.ttl(for: key)
        XCTAssertEqual(ttl, expiration)
    }
}
