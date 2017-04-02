//
//  RedisInteractor.swift
//  XebiaTV
//
//  Created by Simone Civetta on 06/01/17.
//
//

import Foundation
import Redbird

class RedbirdInteractor {
    private static let config = RedbirdConfig(address: "127.0.0.1", port: 6379, password: "foopass")
    
    static func toto() {
        do {
            let client = try Redbird(config: config)
            let response = try client.command("SET", params: ["mykey", "hello_redis"]).toString() //"OK"
        } catch {
            print("Redis error: \(error)")
        }
    }
}
