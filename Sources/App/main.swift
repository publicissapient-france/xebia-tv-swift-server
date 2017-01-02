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
    let liveStreamerResult = launchLiveStreamer(videoId: videoId)
    
    guard let data = liveStreamerResult else {
        return try Response(status: .noContent, json: JSON(node: [:]))
    }
    
    guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable : Any],
        let streams = jsonObject["streams"] as? [AnyHashable : Any]
    else {
        return try Response(status: .noContent, json: JSON(node: [:]))
    }
    
    let urls = streams
        .flatMap { key, value -> Node? in
            guard let stringKey = key as? String,
                let dictValue = value as? [AnyHashable : Any],
                let urlString = dictValue["url"] as? String
            else { return nil }
            
            return Node.object([
                "type": "video/mp4",
                "quality": Node.string(stringKey),
                "url": Node.string(urlString)
            ])
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
