//
//  Predicate.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/06/02.
//  Copyright (c) 2015 tarunon. All rights reserved.
//

import Foundation

private typealias PredicateBuilder = () -> NSPredicate

public struct Predicate {
    private let builder: PredicateBuilder
    private init(builder: PredicateBuilder) {
        self.builder = builder
    }
}

extension Predicate: Builder {
    func build() -> NSPredicate {
        return builder()
    }
    
    public func predicate() -> NSPredicate {
        return build()
    }
}

// MARK: compariison operation
private extension Predicate {
    init<T>(lhs: Expression<T>, rhs: Expression<T>, type: NSPredicateOperatorType) {
        builder = { NSComparisonPredicate(leftExpression: lhs.build(), rightExpression: rhs.build(), modifier: .DirectPredicateModifier, type: type, options: .allZeros) }
    }
}

public func ==<T>(lhs: Expression<T>, rhs: Expression<T>) -> Predicate {
    return Predicate(lhs: lhs, rhs: rhs, type: .EqualToPredicateOperatorType)
}

public func !=<T>(lhs: Expression<T>, rhs: Expression<T>) -> Predicate {
    return Predicate(lhs: lhs, rhs: rhs, type: .NotEqualToPredicateOperatorType)
}

public func ~=<T>(lhs: Expression<T>, rhs: Expression<T>) -> Predicate {
    return Predicate(lhs: lhs, rhs: rhs, type: .LikePredicateOperatorType)
}

public func ><T>(lhs: Expression<T>, rhs: Expression<T>) -> Predicate {
    return Predicate(lhs: lhs, rhs: rhs, type: .GreaterThanPredicateOperatorType)
}

public func >=<T>(lhs: Expression<T>, rhs: Expression<T>) -> Predicate {
    return Predicate(lhs: lhs, rhs: rhs, type: .GreaterThanOrEqualToPredicateOperatorType)
}

public func <<T>(lhs: Expression<T>, rhs: Expression<T>) -> Predicate {
    return Predicate(lhs: lhs, rhs: rhs, type: .LessThanPredicateOperatorType)
}

public func <=<T>(lhs: Expression<T>, rhs: Expression<T>) -> Predicate {
    return Predicate(lhs: lhs, rhs: rhs, type: .LessThanOrEqualToPredicateOperatorType)
}

public func ==<T>(lhs: T, rhs: T) -> Predicate {
    return Expression(value: lhs) == Expression(value: rhs)
}

public func !=<T>(lhs: T, rhs: T) -> Predicate {
    return Expression(value: lhs) != Expression(value: rhs)
}

public func ~=<T>(lhs: T, rhs: T) -> Predicate {
    return Expression(value: lhs) ~= Expression(value: rhs)
}

public func ><T>(lhs: T, rhs: T) -> Predicate {
    return Expression(value: lhs) > Expression(value: rhs)
}

public func >=<T>(lhs: T, rhs: T) -> Predicate {
    return Expression(value: lhs) >= Expression(value: rhs)
}

public func <<T>(lhs: T, rhs: T) -> Predicate {
    return Expression(value: lhs) < Expression(value: rhs)
}

public func <=<T>(lhs: T, rhs: T) -> Predicate {
    return Expression(value: lhs) <= Expression(value: rhs)
}

// MARK: logical operation
private extension Predicate {
    func and(other: Predicate) -> Predicate {
        return Predicate(builder: builder >>> { NSCompoundPredicate(type: .AndPredicateType, subpredicates: [$0, other.build()]) })
    }
    
    func or(other: Predicate) -> Predicate {
        return Predicate(builder: builder >>> { NSCompoundPredicate(type: .OrPredicateType, subpredicates: [$0, other.build()]) })
    }
    
    func not() -> Predicate {
        return Predicate(builder: builder >>> { NSCompoundPredicate(type: .NotPredicateType, subpredicates: [$0]) })
    }
}

public func &&(lhs: Predicate, rhs: Predicate) -> Predicate {
    return lhs.and(rhs)
}

public func ||(lhs: Predicate, rhs: Predicate) -> Predicate {
    return lhs.or(rhs)
}

public prefix func !(rhs: Predicate) -> Predicate {
    return rhs.not()
}