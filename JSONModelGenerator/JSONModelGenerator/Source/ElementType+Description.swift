//
//  ElementType+Description.swift
//  JSONModelGenerator
//
//  Created by Evgeniy on 27.04.18.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation

extension ElementType: CustomStringConvertible {
    public var isObject: Bool {
        switch self {
        case .object:
            return true
        default:
            return false
        }
    }
    
    public var isBaseType: Bool {
        switch self {
        case .int, .double, .string, .arrayType:
            return true
            
        default:
            return false
        }
    }
    
    public var name: String {
        switch self {
        case .any(let name), .array(let name, _),
             .arrayType(let name, _), .double(let name),
             .emptyArray(let name), .int(let name), .null(let name),
             .object(let name, _), .string(let name):
            return name
        default:
            return "no name"
        }
    }
    
    public var elements: [ElementType] {
        switch self {
        case .object(_, let elements), .array(_, let elements):
            return elements
            
        default:
            return [ElementType]()
        }
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
            
        case .array(let name, let type):
            // "WHAT THE FUCK MAN [\(name)]"
            return prettyPrint(name: name, for: self)
            
        case .object(let name, let elements):
            return makeModel(name, of: elements)
            
        case .emptyArray(let name):
            return prettyPrint(name: name, for: self)
            
        case .arrayType(let name, let elementType):
            return prettyPrint(name: name, for: self)
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
