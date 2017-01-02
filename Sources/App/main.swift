import Vapor
import Foundation
import Core
import HTTP

let drop = Droplet()
let dataLoader = DataFile()

drop.get("/categories") { req in
    let fileBody = try dataLoader.load(path: drop.workDir + "Data/categories.json")
    return Response(body: .data(fileBody))
}

drop.get("/playlistItems") { req in
    let fileBody = try dataLoader.load(path: drop.workDir + "Data/youtube.json")
    return Response(body: .data(fileBody))
}

drop.get("/search") { req in
    let fileBody = try dataLoader.load(path: drop.workDir + "Data/youtube_search.json")
    return Response(body: .data(fileBody))
}

drop.get("/video", String.self) { req, videoId in
    guard let urls = try LiveStreamerReader.read(videoId: videoId) else {
        return try Response(status: .noContent, json: JSON(node: [:]))
    }
    return try Response(status: .ok, json: JSON(node: Node.array(urls)))
}

drop.get { req in
    return try drop.view.make("welcome", [
    	"message": drop.localization[req.lang, "welcome", "title"]
    ])
}

drop.resource("posts", PostController())

drop.run()
