//
//  CategoryController.swift
//  XebiaTV
//
//  Created by Simone Civetta on 02/04/17.
//
//

import Foundation
import Vapor
import Core
import HTTP

public protocol CategoryController {
    func categories(_ req: Request) throws -> ResponseRepresentable
}

public final class BaseCategoryController : CategoryController {
    private let dataLoader = DataFile()
    private let drop: Droplet

    public init(drop: Droplet) {
    	self.drop = drop
    }

    public func categories(_ req: Request) throws -> ResponseRepresentable {
        let fileBody = try dataLoader.load(path: drop.workDir + "Data/categories.json")
        return Response(body: .data(fileBody))
    }
}
