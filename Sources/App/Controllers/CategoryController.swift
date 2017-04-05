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

final class CategoryController {
    private let dataLoader = DataFile()

    func categories(_ req: Request) throws -> ResponseRepresentable {
        let fileBody = try dataLoader.load(path: drop.workDir + "Data/categories.json")
        return Response(body: .data(fileBody))
    }
}
