import Vapor
import Foundation
import Core
import HTTP

let drop = Droplet()
let dataLoader = DataFile()

private func apiKey() -> String {
    guard let youtubeApiKey = drop.config["app", "youtube", "apiKey"]?.string else {
        fatalError("No YouTube API Key set")
    }
    return youtubeApiKey
}

private func channelId() -> String {
    guard let youtubeChannelId = drop.config["app", "youtube", "channelId"]?.string else {
        fatalError("No YouTube Channel Id set")
    }
    return youtubeChannelId
}

drop.get("/categories") { req in
    let fileBody = try dataLoader.load(path: drop.workDir + "Data/categories.json")
    return Response(body: .data(fileBody))
}

drop.get("/playlistItems") { req in
    guard let playlistId = req.data["playlistId"]?.string else {
        return Response(status: .badRequest)
    }
    let query = "https://www.googleapis.com/youtube/v3/playlistItems?key=\(apiKey())&maxResults=50&part=snippet&playlistId=\(playlistId)"
    return try drop.client.get(query)
}

drop.get("/search") { req in
    let query = "https://www.googleapis.com/youtube/v3/search?key=\(apiKey())&part=snippet&channelId=\(channelId())&type=video&maxResults=50"
    return try drop.client.get(query)
}

drop.get("/live") { req in
    let query = "https://www.googleapis.com/youtube/v3/search?key=\(apiKey())&part=snippet&eventType=live&type=video&channelId=\(channelId())"
    return try drop.client.get(query)
}

drop.get("/video", String.self) { req, videoId in
    guard let urls = try LiveStreamerReader.read(videoId: videoId) else {
        return try Response(status: .noContent, json: JSON(node: [:]))
    }
    return try Response(status: .ok, json: JSON(node: ["urls": Node.array(urls)]))
}

drop.get { req in
    return try drop.view.make("welcome", [
    	"message": drop.localization[req.lang, "welcome", "title"]
    ])
}

drop.resource("posts", PostController())

drop.run()
