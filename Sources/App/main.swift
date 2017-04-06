import AppLogic
import Vapor

let drop = Droplet()
let loader = try Loader(drop: drop)
try loader.load()
drop.run()
