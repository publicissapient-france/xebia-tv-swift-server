@testable import Vapor
import AppLogic

// cf. https://vapor.github.io/documentation/testing/basic.html
func makeTestDroplet() throws -> Droplet {
    var arguments = CommandLine.arguments.filter {
        $0.hasPrefix("--workdir") || $0.hasPrefix("--config")
    }
    arguments.append("prepare")
    let drop = Droplet(arguments: arguments)
    try load(drop)
    try drop.runCommands()
    return drop
}
