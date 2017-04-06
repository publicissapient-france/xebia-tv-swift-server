//
//  YouTubeController.swift
//  XebiaTV
//
//  Created by Simone Civetta on 02/04/17.
//
//

import Foundation
import Vapor
import Core
import HTTP

final class YouTubeController {
    
    enum Error : Swift.Error {
        case noVideo
    }

    private let drop: Droplet
    private let cacheService: CacheService
    private let googleApisBaseUrl = "https://www.googleapis.com/youtube/v3"
    private let apiKey: String
    private let channelId: String
    private let cacheExpiration: String
    
    init(drop: Droplet, cacheService: CacheService) {
        self.drop = drop
        self.cacheService = cacheService
        
        guard let apiKey = drop.config["app", "youtube", "apiKey"]?.string else { fatalError("No YouTube API Key set") }
        self.apiKey = apiKey
        
        guard let channelId = drop.config["app", "youtube", "channelId"]?.string else { fatalError("No YouTube Channel Id set") }
        self.channelId = channelId
        
        self.cacheExpiration = drop.config["app", "youtube", "cacheExpiration"]?.string ?? "0"
    }
    
    // MARK: - Lists
    
    func playlistItems(_ req: Request) throws -> ResponseRepresentable {
        guard let playlistId = req.data["playlistId"]?.string else {
            return Response(status: .badRequest)
        }
        let query = "\(googleApisBaseUrl)/playlistItems?key=\(apiKey)&maxResults=50&part=snippet&playlistId=\(playlistId)"
        return try drop.client.get(query)
    }
    
    func search(_ req: Request) throws -> ResponseRepresentable {
        let query = "\(googleApisBaseUrl)/search?key=\(apiKey)&part=snippet&channelId=\(channelId)&type=video&maxResults=50"
        return try drop.client.get(query)
    }
    
    func live(_ req: Request) throws -> ResponseRepresentable {
        let query = "\(googleApisBaseUrl)/search?key=\(apiKey)&part=snippet&eventType=live&type=video&channelId=\(channelId)"
        return try drop.client.get(query)
    }
    
    // MARK: - Single Video
    
    func video(_ req: Request, videoId: String) throws -> ResponseRepresentable {
        let cacheKey = "video-\(videoId)"
        guard let cached = try cacheService.load(for: cacheKey) else {
            let urls = try videoUrls(for: videoId)
            try cacheService.save(node: urls, with: cacheKey, expiration: cacheExpiration)
            return try Response(status: .ok, json: JSON(node: urls))
        }
        return try Response(status: .ok, json: JSON(node: cached))
    }
    
    private func videoUrls(for videoId: String) throws -> Node {
        guard let urls = try LiveStreamerReader.read(videoId: videoId) else {
            throw Error.noVideo
        }
        return Node(["urls": Node.array(urls)])
    }
}
