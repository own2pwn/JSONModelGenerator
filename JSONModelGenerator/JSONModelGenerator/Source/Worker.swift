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
    
    // TODO: replace id with ID,
    // if model is array and ends with `s` then remove `s`
    
    private func doKek(_ element: ElementType) -> [String: String] {
        // --- нужно вернуть let results: ResultsModel
        // нужно вернуть models, models[result] = resultsModel
        
        var models: [String: String] = [:]
        
        var result = ""
        
        for property in element.elements {
            if property.isBaseType {
                result += property.description + "\n"
            } else {
                let name = property.name
                let arrayPart = property.isObject ? "\(name.capitalized)Model" : "[\(name.capitalized)Model]"
                result += "let \(name): \(arrayPart)\n"
                
                let recursive = doKek(property)
                models += recursive
            }
        }
        
        models[element.name] = result
        
        return models
    }
    
    public func generate(for object: JSONObject) -> String {
        let parsed = parse(object)
        
        var prettyPrinted = ""
        var models: [ModelType] = []
        
        var strValue = ""
        var nModels: [String: String] = [:]
        
        let r = doKek(parsed[1])
        
        for property in parsed {
            if property.isBaseType {
                strValue += property.description + "\n"
            } else {
                let name = property.name
                let arrayPart = property.isObject ? "\(name.capitalized)Model\n" : "[\(name.capitalized)Model]\n"
                strValue += "let \(name): \(arrayPart)"
                
                var nValue = ""
                
                for inner in property.elements {
                    // начинаем строить NameModel
                    if inner.isBaseType {
                        nValue += inner.description + "\n"
                    } else {
                        let innerName = inner.name
                        let innerArrayPart = inner.isObject ? "\(innerName.capitalized)Model\n" : "[\(innerName.capitalized)Model]\n"
                        nValue += "let \(innerName): \(innerArrayPart)"
                        
                        // PhotoModel
                        
                        var nValue2 = ""
                        
                        for inner2 in inner.elements {
                            // building PhotoModel
                            if inner2.isBaseType {
                                nValue2 += inner2.description + "\n"
                            } else {
                                let innerName2 = inner2.name
                                let innerArrayPart2 = inner2.isObject ? "\(innerName2.capitalized)Model\n" : "[\(innerName2.capitalized)Model]\n"
                                nValue2 += "let \(innerName2): \(innerArrayPart2)"
                            }
                        }
                        
                        nModels[innerName] = nValue2
                    }
                }
                
                nModels[name] = nValue
            }
        }
        
        for property in parsed {
            break
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
                let properties = elements.map { Property(name: $0.name, type: $0) }
                result.append(ModelType(name: name, properties: properties))
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
