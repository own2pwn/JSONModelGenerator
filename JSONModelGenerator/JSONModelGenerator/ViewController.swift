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

    case array(name: String, elements: [ElementType])
    case object(name: String, elements: [ElementType])

    case arrayType(name: String, elementType: String)
    case emptyArray(name: String)
}

extension ElementType: CustomStringConvertible {
    public var isObject: Bool {
        switch self {
        case .object:
            return true
        default:
            return false
        }
    }

    public var name: String {
        switch self {
        case .object(let name, _):
            return name
        default:
            return "no name"
        }
    }

    public var elements: [ElementType] {
        switch self {
        case .object(_, let elements):
            return elements

        case .array(_, let elements):
            return elements

        default:
            return [ElementType]()
        }
    }

    private func prettyPrint(name: String, for type: ElementType) -> String {
        let prettyName = name.prettyPrintedProperty
        var pretty = "let \(prettyName): \(type.typeName)"

        if name != prettyName {
            pretty += " // EPParser:map:\(name)"
        }

        return pretty
    }

    public var typeName: String {
        switch self {
        case .string, .stringType:
            return "String"

        case .int:
            return "Int"

        case .double:
            return "Double"

        case .any:
            return "Any"

        case .null:
            return "Any?"

        case .array(_, let type):
            return "[\(type)]"

        case .object:
            return ""

        case .emptyArray:
            return "[Any]"
        case .arrayType(_, let elementType):
            return "[\(elementType)]"
        }
    }

    public var description: String {
        switch self {
        case .string(let name):
            return prettyPrint(name: name, for: self)

        case .stringType:
            return "String"

        case .int(let name):
            return prettyPrint(name: name, for: self)

        case .double(let name):
            return prettyPrint(name: name, for: self)

        case .any(let name):
            return prettyPrint(name: name, for: self)

        case .null(let name):
            return prettyPrint(name: name, for: self)

        case .array(let name, _):
            return "WHAT THE FUCK MAN" //prettyPrint(name: name, for: self)

        case .object(let name, let elements):
            return makeModel(name, of: elements)

        case .emptyArray(let name):
            return prettyPrint(name: name, for: self)

        case .arrayType(let name, let elementType):
            return prettyPrint(name: name, for: self)
        }
    }

    private func makeModel(_ name: String, of elements: [ElementType]) -> String {
        let spacing = String(repeating: Character.space, count: 4)
        let header = "struct \(name.prettyPrintedProperty.capitalized)Model {\n"

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

private extension String {
    var prettyPrintedProperty: String {
        let splitted = components(separatedBy: "_")
        guard splitted.count > 1 else {
            return self
        }
        let pretty = splitted[1..<splitted.count].map { $0.capitalized }
        let full = [splitted[0]] + pretty

        return full.joined()
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

public struct ModelType {
    let name: String
    let properties: [ElementType]
}

public final class WorkerBox {

    // MARK: - Interface

    public func generate(for object: JSONObject) -> String {
        let parsed = parse(object)

        var prettyPrinted = ""
        var models: [ModelType] = []

        for property in parsed {
            switch property {
            case .array(let name, let elements):
                // models.append(ModelType(name: name, properties: elements))
                models += prettyPrintObject(elements: elements, name: name)
                prettyPrinted += "let \(name): \(name.capitalized)Model\n"
            default:
                prettyPrinted += property.description + "\n"
            }
        }

        return prettyPrinted
    }

    private func prettyPrintObject(elements: [ElementType], name: String) -> [ModelType] {
        var result: [ModelType] = []

        for element in elements {
            if element.isObject {
                let traversed = prettyPrintObject(elements: element.elements, name: element.name)
                result += traversed
            } else {
                result.append(ModelType(name: name, properties: elements))
            }
        }

        return result
    }

    private func traverse(models: [ModelType]) -> [ModelType] {
        var result: [ModelType] = []

        for model in models {
            for property in model.properties {
                if property.isObject {
                    result.append(ModelType(name: model.name, properties: property.elements))
                }
            }
        }

        return result
    }

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

            return ElementType.array(name: name, elements: parsed)
        }
        if element is String {
            return .arrayType(name: name, elementType: ElementType.stringType.description)
        }

        return parse(element: element, name: name)
    }

    private func makeEmptyArray(for name: String) -> ElementType {
        return .emptyArray(name: name)
    }

    private func makeString(for name: String) -> ElementType {
        return .string(name: name)
    }
}

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
