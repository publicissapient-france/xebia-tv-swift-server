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
    
    func playlistItems(_ req: Request) throws -> ResponseRepresentable {
        guard let playlistId = req.data["playlistId"]?.string else {
            return Response(status: .badRequest)
        }
        let query = "https://www.googleapis.com/youtube/v3/playlistItems?key=\(apiKey())&maxResults=50&part=snippet&playlistId=\(playlistId)"
        return try drop.client.get(query)
    }
    
    func search(_ req: Request) throws -> ResponseRepresentable {
        let query = "https://www.googleapis.com/youtube/v3/search?key=\(apiKey())&part=snippet&channelId=\(channelId())&type=video&maxResults=50"
        return try drop.client.get(query)
    }
    
    func live(_ req: Request) throws -> ResponseRepresentable {
        let query = "https://www.googleapis.com/youtube/v3/search?key=\(apiKey())&part=snippet&eventType=live&type=video&channelId=\(channelId())"
        return try drop.client.get(query)
    }
    
    func video(_ req: Request, videoId: String) throws -> ResponseRepresentable {
        guard let urls = try LiveStreamerReader.read(videoId: videoId) else {
            return try Response(status: .noContent, json: JSON(node: [:]))
        }
        return try Response(status: .ok, json: JSON(node: ["urls": Node.array(urls)]))
    }
}
