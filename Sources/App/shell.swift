//
//  shell.swift
//  XebiaTV
//
//  Created by Simone Civetta on 29/12/16.
//
//

import Foundation

public func shell(_ command: String, args: [String] = []) -> (Bool, Data?) {
    
    let task = Process()
    task.launchPath = command
    task.arguments = args
    
    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    task.waitUntilExit()

    return (task.terminationReason == .exit, data)
}
