import Foundation
import Vapor
import VaporRedis

public func load(_ drop: Droplet) throws {
    try drop.addProvider(VaporRedis.Provider(config: drop.config))
    let cacheService = RedisService(drop: drop)

    let categoryController = BaseCategoryController(drop: drop)
    let youTubeController = BaseYouTubeController(drop: drop, cacheService: cacheService)
    return try load(drop, categoryController: categoryController, youTubeController: youTubeController)
}

public func load(_ drop: Droplet, categoryController: CategoryController, youTubeController: YouTubeController) throws {
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
