import Foundation
import Vapor

class LiveStreamerReader {
    static func read(videoId: String, commandInteractor: CommandInteractor.Type = UnixCommandInteractor.self) throws ->[Node]? {
        let liveStreamerResult = commandInteractor.launch("/usr/local/bin/livestreamer", args: ["https://www.youtube.com/watch?v=" + videoId, "--json", "--stream-url", "--yes-run-as-root"])
       
        guard let data = liveStreamerResult else {
            return nil
        }
        
        guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable : Any],
            let streams = jsonObject["streams"] as? [AnyHashable : Any]
        else {
            return nil
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
        return urls
    }
}
