import Foundation

protocol CommandInteractor {
    static func launch(_ command: String, args: [String]) -> Data
}

class UnixCommandInteractor : CommandInteractor {
    static func launch(_ command: String, args: [String] = []) -> Data {
        #if os(Linux)
            let task = Task()
        #else
            let task = Process()
        #endif
        
        let pipe = Pipe()
        task.launchPath = command
        task.arguments = args
        task.standardOutput = pipe
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        task.waitUntilExit()
        
        return data
    }
}
