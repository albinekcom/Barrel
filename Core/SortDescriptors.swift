//
//  NSSortDescriptor.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/11/09.
//  Copyright © 2015年 tarunon. All rights reserved.
//

import Foundation

public struct SortDescriptors {
    public let value: [NSSortDescriptor]
    
    private init(_ value: [NSSortDescriptor]) {
        self.value = value
    }
    
    fileprivate init<T: Comparable, A: AttributeType>(lhs: A, rhs: A, ascending: Bool) where A.ValueType == T {
        if rhs.keyPath.string.hasPrefix("_.") {
            self.init([NSSortDescriptor(key: lhs.keyPath.string, ascending: ascending)])
        } else if lhs.keyPath.string.hasPrefix("_.") {
            self.init([NSSortDescriptor(key: rhs.keyPath.string, ascending: !ascending)])
        } else {
            self.init([])
        }
    }
    
    fileprivate init(lhs: SortDescriptors, rhs: SortDescriptors) {
        self.init(lhs.value + rhs.value)
    }
}

extension Attribute {
    public static func sortAttributeFirst() -> Attribute {
        return Attribute()
    }

    public static func sortAttributeSecond() -> Attribute {
        return Attribute(name: "_")
    }
}

public func ><T: Comparable, A: AttributeType>(lhs: A, rhs: A) -> SortDescriptors where A.ValueType == T {
    return SortDescriptors(lhs: lhs, rhs: rhs, ascending: false)
}

public func <<T: Comparable, A: AttributeType>(lhs: A, rhs: A) -> SortDescriptors where A.ValueType == T {
    return SortDescriptors(lhs: lhs, rhs: rhs, ascending: true)
}

public func &(lhs: SortDescriptors, rhs: SortDescriptors) -> SortDescriptors {
    return SortDescriptors(lhs: lhs, rhs: rhs)
}
