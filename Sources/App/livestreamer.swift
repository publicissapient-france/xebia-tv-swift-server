//
//  shell.swift
//  XebiaTV
//
//  Created by Simone Civetta on 29/12/16.
//
//

import Foundation

func launchLiveStreamer(videoId: String) -> Data? {
    return shell("/usr/local/bin/livestreamer", args: ["https://www.youtube.com/watch?v=" + videoId, "--json", "--stream-url", "--yes-run-as-root"])
}

private func shell(_ command: String, args: [String] = []) -> Data? {
    
    #if os(Linux)
        let task = Task()
    #else
        let task = Process()
    #endif
    task.launchPath = command
    task.arguments = args
    
    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    task.waitUntilExit()

    return data
}
