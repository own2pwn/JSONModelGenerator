//
//  ViewController.swift
//  JSONModelGenerator
//
//  Created by Evgeniy on 27.04.18.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Cocoa

public final class WorkerNew {

    // MARK: - Interface

    public func parse(_ object: JSONObject) -> [String] {
        let w = WorkerBox()
        let v = w.generate(for: object)
        let k = v.description

        return [""]

        var properties: [String] = []

        for key in object.keys {
            let element = object[key]!

            let property = parse(element: element, name: key)
            properties.append(property)
        }

        return properties
    }

    // MARK: - Internal

    private func parse(element: Any, name: String) -> String {
        if element is String {
            return makeString(for: name)
        }
        if element is [Any] {
            return makeArray(element as! [Any], for: name)
        }

        return "not yet! [\(name)]"
    }

    private func makeArray(_ array: [Any], for name: String) -> String {
        guard !array.isEmpty else { return makeEmptyArray(for: name) }
        let element = array[0]

        if element is JSONObject {
            let model = parse(element as! JSONObject)
            log.debug(model)
        }

        return "array not yet!"
    }

    private func makeEmptyArray(for name: String) -> String {
        return "let \(name): [Any]"
    }

    private func makeString(for name: String) -> String {
        return "let \(name): String"
    }
}

public final class Worker {

    // MARK: - Interface

    // TODO: parse tries parse object, then parseArray

    public func parse() {
        let path = "file://" + FileManager.default.currentDirectoryPath + "/Model.json"
        guard let url = URL(string: path),
            let content = try? Data(contentsOf: url),
            let object = try? JSONSerialization.jsonObject(with: content, options: []),
            let json = object as? JSONObject else { return }

        let w = WorkerNew()
        w.parse(json)
        return;

        var properties: [String] = []

        for key in json.keys {
            let element = json[key]!
            let type = process(element)
            let property = buildProperty(name: key, type: type)

            properties.append(property)
        }

        log.debug(properties)
    }

    // MARK: - Internal

    private func buildProperty(name: String, type: String) -> String {
        return "let \(name): \(type)"
    }

    private func process(_ element: Any) -> String {
        if element is Array<Any> {
            return processArray(element as! [Any])
        }
        if element is String {
            return processString(element as! String)
        }

        return "unknown"
    }

    private func processArray(_ array: Array<Any>) -> String {
        if array.isEmpty {
            let returnType = [Any].self
            log.debug("return - \(returnType)")

            return "\(returnType)"
        }
        let element = array[0]

        if element is JSONObject {
            processArrayObject(element as! JSONObject)
        }

        return "unknown"
    }

    private func processArrayObject(_ object: JSONObject) {
        for key in object.keys {
            let element = object[key]
            let t = element as? Int
        }
    }

    private func processString(_ str: String) -> String {
        return "\(String.self)"
    }
}

final class ViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        testWorker()
    }

    private func testWorker() {
        let worker = Worker()
        worker.parse()
    }
}

struct SearchModel {
    let status: String
    struct ResultsModel {
        struct GeometryModel {
            struct ViewportModel {
                struct NortheastModel {
                    let lat: Double
                    let lng: Double
                }

                struct SouthwestModel {
                    let lat: Double
                    let lng: Double
                }
            }

            struct LocationModel {
                let lat: Double
                let lng: Double
            }
        }

        let reference: String
        let icon: String
        let name: String
        let id: String
        let place_id: String
        struct PhotosModel {
            let photo_reference: String
            let height: Int
            let html_attributions: [String]
            let width: Int
        }

        /*
         for type in element.types {
            if type.isObject {
                /
            }
         }
        */

        let scope: String
        let vicinity: String
        let types: [String]
    }

    let html_attributions: [Any]
    let next_page_token: String
}
