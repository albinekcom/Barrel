//
//  Group.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/06/04.
//  Copyright (c) 2015年 tarunon. All rights reserved.
//

import Foundation
import CoreData

public struct Group<T: NSManagedObject> {
    internal let context: NSManagedObjectContext
    internal let builder: Builder<NSFetchRequest>
    
    internal init(context: NSManagedObjectContext, builder: Builder<NSFetchRequest>, @autoclosure(escaping) keyPath: () -> String) {
        self.context = context
        self.builder = builder.map { (fetchRequest: NSFetchRequest) -> NSFetchRequest in
            fetchRequest.propertiesToGroupBy = [keyPath()]
            fetchRequest.havingPredicate = NSPredicate(value: true)
            return fetchRequest
        }
    }
    
    internal init(context: NSManagedObjectContext, builder: Builder<NSFetchRequest>) {
        self.context = context
        self.builder = builder
    }
    
    public func fetchRequest() -> NSFetchRequest {
        return builder.build()
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
        return Group(context: context, builder: builder.map { (fetchRequest: NSFetchRequest) -> NSFetchRequest in
            fetchRequest.propertiesToGroupBy = fetchRequest.propertiesToGroupBy! + [keyPath()]
            return fetchRequest
            })
    }
    func having(@autoclosure(escaping) predicate: () -> NSPredicate) -> Group {
        return Group(context: context, builder: builder.map { (fetchRequest: NSFetchRequest) -> NSFetchRequest in
            fetchRequest.havingPredicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [fetchRequest.havingPredicate!, predicate()])
            return fetchRequest
            })
    }
}

// MARK: group methods via attribute
public extension Group {
    public func having(predicate: (T -> Predicate)) -> Group {
        return having(predicate(self.context.attribute()).predicate())
    }
    
    public func groupBy<E: ExpressionType>(argument: (T) -> E) -> Group {
        return groupBy(Expression.createExpression(argument(self.context.attribute())).name())
    }
}
