//
//  ElementType.swift
//  JSONModelGenerator
//
//  Created by Evgeniy on 27.04.18.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation

public typealias JSONObject = [String: Any]

public enum ElementType {
    case string(name: String)
    case stringType
    
    case int(name: String)
    case intType
    
    case double(name: String)
    case doubleType
    
    case any(name: String)
    case null(name: String)
    
    case array(name: String, elements: [ElementType])
    case object(name: String, elements: [ElementType])
    
    case arrayType(name: String, elementType: String)
    case emptyArray(name: String)
}
