import XCTest
@testable import Vapor
import HTTP
import AppLogic

class CacheServiceTests: XCTestCase {
    
    func testExpiration() throws {
        let drop = try makeTestDroplet()
        let key = "A"
        
        let redisService = RedisService(drop: drop)
        let node = Node(stringLiteral: "a-value")
        try redisService.save(node: node, with: key, expiration: "30")
        
        let ttl = try redisService.ttl(for: key)
        XCTAssertEqual(ttl, 30)
    }
}
