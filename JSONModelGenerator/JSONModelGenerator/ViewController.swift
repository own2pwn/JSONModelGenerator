//
//  ViewController.swift
//  JSONModelGenerator
//
//  Created by Evgeniy on 27.04.18.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Cocoa

public typealias JSONObject = [String: Any]

public enum ElementType {
    case string(name: String)
    case stringType

    case int(name: String)
    case double(name: String)

    case any(name: String)
    case null(name: String)

    indirect
    case array(name: String, elements: ElementType)
    case object(name: String, elements: [ElementType])
    case arrayType(name: String)
}

extension ElementType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .string(let name):
            return "let \(name): String"

        case .arrayType(let name):
            return "let \(name): [Any]"

        case .array(let name, let type):
            return "let \(name): [\(type)]"

        case .int(let name):
            return "let \(name): Int"

        case .double(let name):
            return "let \(name): Double"

        case .object(let name, let elements):
            return makeModel(name, of: elements)

        case .any(let name):
            return "let \(name): Any"

        case .null(let name):
            return "let \(name): Any?"

        case .stringType:
            return "String"
        }
    }

    private func makeModel(_ name: String, of elements: [ElementType]) -> String {
        let spacing = String(repeating: Character.space, count: 4)
        let header = "struct \(name.capitalized)Model {\n"

        let content = elements
            .map { spacing + $0.description }
            .joined(separator: "\n")

        let footer = "\n}"

        return header + content + footer
    }

    private func makeModel(of elements: [Property]) -> String {
        let spacing = String(repeating: Character.space, count: 4)
        let content = elements
            .map { "\(spacing)let \($0.name): \($0.type)" }
            .joined(separator: "\n")

        return content
    }
}

public extension Character {
    public static var space: Character {
        return " "
    }
}

public extension String {
    public static var space: String {
        return " "
    }
}

public struct Property {
    let name: String
    let type: ElementType
}

public final class WorkerBox {

    // MARK: - Interface

    public func parse(_ object: JSONObject) -> [ElementType] {
        var properties: [ElementType] = []

        for key in object.keys {
            let element = object[key]!

            let property = parse(element: element, name: key)
            properties.append(property)
        }

        return properties
    }

    // MARK: - Internal

    private func parse(element: Any, name: String) -> ElementType {
        if element is String {
            return makeString(for: name)
        }

        if element is JSONObject {
            let parsed = parse(element as! JSONObject)

            return .object(name: name, elements: parsed)
        }

        if element is [Any] {
            return makeArray(element as! [Any], for: name)
        }

        if element is Int {
            return makeInt(for: name)
        }

        if element is Double {
            return makeDouble(for: name)
        }

        return .null(name: name)
    }

    private func makeDouble(for name: String) -> ElementType {
        return .double(name: name)
    }

    private func makeInt(for name: String) -> ElementType {
        return .int(name: name)
    }

    private func makeArray(_ array: [Any], for name: String) -> ElementType {
        guard !array.isEmpty else { return makeEmptyArray(for: name) }
        let element = array[0]

        if element is JSONObject {
            let parsed = parse(element as! JSONObject)

            return .object(name: name, elements: parsed)
        }
        if element is String {
            return .array(name: name, elements: .stringType)
        }

        return parse(element: element, name: name)
    }

    private func makeEmptyArray(for name: String) -> ElementType {
        return .arrayType(name: name)
    }

    private func makeString(for name: String) -> ElementType {
        return .string(name: name)
    }
}

public final class WorkerNew {

    // MARK: - Interface

    public func parse(_ object: JSONObject) -> [String] {
        let w = WorkerBox()
        let v = w.parse(object)
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
