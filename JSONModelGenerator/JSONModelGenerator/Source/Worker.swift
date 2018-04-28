//
//  Worker.swift
//  JSONModelGenerator
//
//  Created by Evgeniy on 27.04.18.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation

public struct Property {
    let name: String
    let type: ElementType
}

extension Property: CustomStringConvertible {
    public var description: String {
        return "let \(name): \(type.typeName)"
    }
}

public struct ModelType {
    let name: String
    let properties: [Property]
}

public extension Dictionary {
    public static func +=(_ lhs: inout Dictionary<Key, Value>, _ rhs: Dictionary<Key, Value>) {
        for (k, v) in rhs {
            lhs[k] = v
        }
    }
}

public final class Worker {

    // MARK: - Interface
    
    // TODO: if model is array and ends with `s` then remove `s`
    
    private func traverseStruct(_ element: ElementType) -> [String: String] {
        var models: [String: String] = [:]
        var result = ""
        let spacing = String(repeating: Character.space, count: 4)
        
        for property in element.elements {
            if property.isBaseType {
                result += spacing + property.description + "\n"
            } else {
                let name = property.name
                let arrayPart = property.isObject ? "\(name.capitalized)Model" : "[\(name.capitalized)Model]"
                result += spacing + "let \(name): \(arrayPart)\n"
                
                let recursive = traverseStruct(property)
                models += recursive
            }
        }
        models[element.name] = result
        
        return models
    }
    
    public func generate(name: String, for object: JSONObject) -> String {
        let parsed = parse(object)
        let modelName = name.capitalized + "Model"
        
        let baseKey = "container"
        let container = ElementType.object(name: baseKey, elements: parsed)
        var elements = traverseStruct(container)
        let baseModel = elements[baseKey]!
        
        var prettyPrinted = makeBaseModel(name: modelName, baseModel)
        elements[baseKey] = nil
        
        for (k, v) in elements {
            let propertyModel = k.capitalized + "Model"
            prettyPrinted += makeBaseModel(name: propertyModel, v)
        }
        
        return prettyPrinted
    }
    
    private func makeBaseModel(name: String, _ properties: String) -> String {
        let header = "struct \(name) {\n"
        let footer = "}\n\n"
        
        return header + properties + footer
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
