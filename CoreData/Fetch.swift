//
//  Fetch.swift
//  BarrelCoreData
//
//  Created by Nobuo Saito on 2015/11/09.
//  Copyright © 2015年 tarunon. All rights reserved.
//

import Foundation
import CoreData
import Barrel

public struct Fetch<T: NSManagedObject> {
    public let context: NSManagedObjectContext
    internal let builder: Builder<NSFetchRequest<T>>
    
    internal init(context: NSManagedObjectContext, builder: Builder<NSFetchRequest<T>>) {
        self.context = context
        self.builder = builder
    }
    
    internal init(context: NSManagedObjectContext) {
        self.init(context: context, builder: Builder {
            let fetchRequest = NSFetchRequest<T>(entityName: context.entityName(T.self)!)
            fetchRequest.predicate = NSPredicate(value: true)
            fetchRequest.sortDescriptors = []
            return fetchRequest
        })
    }
}

extension Fetch: Executable {
    public typealias ElementType = T

    public func fetchRequest() -> NSFetchRequest<T> {
        let fetchRequest = self.builder.build()
        return fetchRequest
    }
    
    public func delete() {
        self.forEach { self.context.delete($0) }
    }
}

extension Fetch {
    public func filter(_ predicate: @autoclosure @escaping () -> NSPredicate) -> Fetch {
        return Fetch(
            context: self.context,
            builder: self.builder.map {
                $0.predicate = NSCompoundPredicate(type: .and, subpredicates: [$0.predicate!, predicate()])
                return $0
            }
        )
    }
    
    public func sorted(_ sortDescriptor: @autoclosure @escaping () -> [NSSortDescriptor]) -> Fetch {
        return Fetch(
            context: self.context,
            builder: self.builder.map {
                $0.sortDescriptors = $0.sortDescriptors! + sortDescriptor()
                return $0
            }
        )
    }
    
    public func limit(_ limit: Int) -> Fetch {
        return Fetch(
            context: self.context,
            builder: self.builder.map {
                $0.fetchLimit = limit
                return $0
            }
        )
    }
    
    public func offset(_ offset: Int) -> Fetch {
        return Fetch(
            context: self.context,
            builder: self.builder.map {
                $0.fetchOffset = offset
                return $0
            }
        )
    }
}

public extension Fetch {
    @available(*, renamed: "brl.filter")
    public func brl_filter(_ f: @escaping (Attribute<T>) -> Predicate) -> Fetch {
        return self.filter(f(Attribute()).value)
    }
    
    @available(*, renamed: "brl.sorted")
    public func brl_sorted(_ f: @escaping (Attribute<T>, Attribute<T>) -> SortDescriptors) -> Fetch {
        return self.sorted(f(Attribute.sortAttributeFirst(), Attribute.sortAttributeSecond()).value)
    }
}
