//
//  Group.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/06/04.
//  Copyright (c) 2015年 tarunon. All rights reserved.
//

import Foundation
import CoreData

public struct Group<T: NSManagedObject>: Builder, Executable {
    internal let context: NSManagedObjectContext
    internal let builder: RequestBuilder
    
    internal init(context: NSManagedObjectContext, builder: RequestBuilder, @autoclosure(escaping) keyPath: () -> String) {
        self.context = context
        self.builder = builder >>> { (fetchRequest: NSFetchRequest) -> NSFetchRequest in
            fetchRequest.propertiesToGroupBy = [keyPath()]
            fetchRequest.havingPredicate = NSPredicate(value: true)
            return fetchRequest
        }
    }
    
    internal init(context: NSManagedObjectContext, builder: RequestBuilder) {
        self.context = context
        self.builder = builder
    }
}

extension Group: Builder {
    func build() -> NSFetchRequest {
        let fetchRequest = builder()
        fetchRequest.resultType = .DictionaryResultType
        return fetchRequest
    }
    
    public func fetchRequest() -> NSFetchRequest {
        return build()
    }
}

extension Group: Executable {
    public func execute() -> ExecuteResult<[String: AnyObject]> {
        return _execute(self)
    }
    
    public func count() -> CountResult {
        return _count(self)
    }
}

// MARK: group methods
public extension Group {
    func groupBy(@autoclosure(escaping) keyPath: () -> String) -> Group {
        return Group(context: context, builder: builder >>> { (fetchRequest: NSFetchRequest) -> NSFetchRequest in
            fetchRequest.propertiesToGroupBy = fetchRequest.propertiesToGroupBy! + [keyPath()]
            return fetchRequest
            })
    }
    func having(@autoclosure(escaping) predicate: () -> NSPredicate) -> Group {
        return Group(context: context, builder: builder >>> { (fetchRequest: NSFetchRequest) -> NSFetchRequest in
            fetchRequest.havingPredicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [fetchRequest.havingPredicate!, predicate()])
            return fetchRequest
            })
    }
}

// MARK: group methods via attribute
public extension Group {
    public func having(predicate: (T -> Predicate)) -> Group {
        return having(predicate(T.attribute()).build())
    }
    
    public func groupBy<U>(keyPath: (T) -> U) -> Group {
        return groupBy(keyPath(T.attribute()) as! String)
    }
    
    public func groupBy<U>(keyPath: (T) -> Expression<U>) -> Group {
        return groupBy(keyPath(T.attribute()).build().keyPath)
    }
}
