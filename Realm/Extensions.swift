//
//  Extensions.swift
//  BarrelRealm
//
//  Created by Nobuo Saito on 2015/11/10.
//  Copyright © 2015年 tarunon. All rights reserved.
//

import Foundation
import RealmSwift
import Barrel

extension Object: ExpressionType {
    public typealias ValueType = Object
}

extension List: ExpressionType, ManyType {
    public typealias ValueType = List
    public typealias ElementType = T
}

extension LinkingObjects: ExpressionType, ManyType {
    public typealias ValueType = LinkingObjects
    public typealias ElementType = T
}

private extension NSSortDescriptor {
    func toRealmObject() -> SortDescriptor {
        return SortDescriptor(property: self.key!, ascending: ascending)
    }
}

public extension Realm {
    func objects<T: Object>() -> Results<T> {
        return self.objects(T.self)
    }
}

public extension ExpressionType where Self: Object {
    public typealias ValueType = Self
    public static func objects(_ realm: Realm) -> Results<Self> {
        return realm.objects()
    }
    
    public static func insert(_ realm: Realm) -> Self {
        let object = Self()
        realm.add(object)
        return object
    }
}

public extension RealmCollection where Element: ExpressionType {
    func brl_filter(_ f: (Attribute<Element>) -> Predicate) -> Results<Element> {
        return self.filter(f(Attribute()).value)
    }

    func brl_indexOf(_ f: (Attribute<Element>) -> Predicate) -> Int? {
        return self.index(matching: f(Attribute()).value)
    }
    
    func brl_sorted(_ f: (Attribute<Element>, Attribute<Element>) -> SortDescriptors) -> Results<Element> {
        return self.sorted(by: f(Attribute(), Attribute(name: "sort")).value.map { $0.toRealmObject() })
    }
    
    func brl_min<U: MinMaxType>(_ f: (Attribute<Element>) -> Attribute<U>) -> U? {
        return self.min(ofProperty: f(Attribute()).keyPath.string)
    }
    
    func brl_max<U: MinMaxType>(_ f: (Attribute<Element>) -> Attribute<U>) -> U? {
        return self.max(ofProperty: f(Attribute()).keyPath.string)
    }
    
    func brl_sum<U: AddableType>(_ f: (Attribute<Element>) -> Attribute<U>) -> U {
        return self.sum(ofProperty: f(Attribute()).keyPath.string)
    }
    
    func brl_average<U: AddableType>(_ f: (Attribute<Element>) -> Attribute<U>) -> U? {
        return self.average(ofProperty: f(Attribute()).keyPath.string)
    }
}
