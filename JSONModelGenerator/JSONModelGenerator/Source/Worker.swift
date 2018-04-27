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
                traverseObject(property)
            default:
                prettyPrinted += property.description + "\n"
            }
        }
        
        return prettyPrinted
    }
    
    private func traverseObject(_ object: ElementType) {
        var result: [ModelType] = []
        
        for element in object.elements {
        }
        
        return // result[0]
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
