import Foundation
import Vapor
import VaporRedis

public struct Loader {
    public let drop: Droplet
    public let categoryController: CategoryController
    public let youTubeController: YouTubeController
    
    public init(drop: Droplet, categoryController: CategoryController? = nil, youTubeController: YouTubeController? = nil) throws {
        self.drop = drop
        self.categoryController = categoryController ?? BaseCategoryController(drop: drop)
        
        if let youTubeController = youTubeController {
            self.youTubeController = youTubeController
        }
        else {
            let cacheService = try RedisService(drop: drop)
            self.youTubeController = youTubeController ?? BaseYouTubeController(drop: drop, cacheService: cacheService)
        }
    }
    
    public func load() throws {
        try setupRoutes(drop, categoryController: categoryController, youTubeController: youTubeController)
    }
}

func setupRoutes(_ drop: Droplet, categoryController: CategoryController, youTubeController: YouTubeController) throws {
    drop.get("/categories", handler: categoryController.categories)
    drop.get("/playlistItems", handler: youTubeController.playlistItems)
    drop.get("/search", handler: youTubeController.search)
    drop.get("/live", handler: youTubeController.live)
    drop.get("/video", String.self, handler: youTubeController.video)
    
    drop.get { req in
        return try drop.view.make("welcome", [
            "message": drop.localization[req.lang, "welcome", "title"]
        ])
    }
}
