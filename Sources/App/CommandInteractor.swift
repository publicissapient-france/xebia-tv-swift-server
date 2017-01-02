import Foundation

protocol CommandInteractor {
    static func launch(_ command: String, args: [String]) -> Data?
}

class UnixCommandInteractor : CommandInteractor {
    static func launch(_ command: String, args: [String] = []) -> Data? {
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
}
