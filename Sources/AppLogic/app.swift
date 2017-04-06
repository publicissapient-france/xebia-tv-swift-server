import Foundation
import Vapor
import VaporRedis

public func load(_ drop: Droplet) throws {
    try drop.addProvider(VaporRedis.Provider(config: drop.config))
    let categoryController = CategoryController(drop: drop)
    let youtubeController = YouTubeController(drop: drop)
    
    drop.get("/categories", handler: categoryController.categories)
    drop.get("/playlistItems", handler: youtubeController.playlistItems)
    drop.get("/search", handler: youtubeController.search)
    drop.get("/live", handler: youtubeController.live)
    drop.get("/video", String.self, handler: youtubeController.video)
    
    drop.get { req in
        return try drop.view.make("welcome", [
            "message": drop.localization[req.lang, "welcome", "title"]
        ])
    }
}
