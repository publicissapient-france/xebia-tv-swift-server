import XCTest
@testable import Vapor
import HTTP
import AppLogic

class AppTests: XCTestCase {
    
    class StubCategoryController : CategoryController {
        func categories(_ req: Request) throws -> ResponseRepresentable {
            return JSON(Node(dictionaryLiteral: ("categories", "someCategory")))
        }
    }
    
    func testCategoryRoute() throws {
        let drop = try makeTestDroplet(categoryController: StubCategoryController())
        
        let request = try Request(method: .get, uri: "/categories")
        let response = try drop.respond(to: request)
        let jsonBody = try JSON(bytes: response.body.bytes!)
        
        XCTAssertEqual(jsonBody["categories"]?.string, "someCategory")
    }
}
