@testable import Vapor
import AppLogic

// cf. https://vapor.github.io/documentation/testing/basic.html
func makeTestDroplet(categoryController: CategoryController? = nil, youTubeController: YouTubeController? = nil) throws -> Droplet {
    var arguments = CommandLine.arguments.filter {
        $0.hasPrefix("--workdir") || $0.hasPrefix("--config")
    }
    arguments.append("prepare")
    let drop = Droplet(arguments: arguments)
    let loader = try Loader(drop: drop, categoryController: categoryController, youTubeController: youTubeController)
    try loader.load()
    try drop.runCommands()
    return drop
}
