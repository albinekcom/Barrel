//
//  ExpressionTest.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/07/06.
//  Copyright (c) 2015年 tarunon. All rights reserved.
//

import UIKit
import XCTest
import Barrel
import CoreData

class ExpressionTest: XCTestCase {

    var context: NSManagedObjectContext!
    var storeURL = NSURL(fileURLWithPath: "test.db")!
    
    override func setUp() {
        super.setUp()
        context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: NSManagedObjectModel(contentsOfURL: NSBundle(forClass: self.classForCoder).URLForResource("Person", withExtension: "momd")!)!)
        context.persistentStoreCoordinator?.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL:storeURL , options: nil, error: nil)
    }
    
    override func tearDown() {
        context.save(nil)
        NSFileManager.defaultManager().removeItemAtURL(storeURL, error: nil)
        super.tearDown()
    }

    func testAdd() {
        context.fetch(Person).filter {
            let e1: Expression<NSNumber> = $0.age + 1
            XCTAssertEqual(e1.name(), "add_age_to_1", "Pass")
            XCTAssertEqual(e1.expression(), NSExpression(forFunction: "add:to:", arguments: [NSExpression(forKeyPath: "age"), NSExpression(forConstantValue: 1)]), "Pass")
            let e2: Expression<NSNumber> = $0.age + $0.age
            XCTAssertEqual(e2.name(), "add_age_to_age", "Pass")
            XCTAssertEqual(e2.expression(), NSExpression(forFunction: "add:to:", arguments: [NSExpression(forKeyPath: "age"), NSExpression(forKeyPath: "age")]), "Pass")
            return e1 < e2
        }.execute()
    }
    
    func testSubtract() {
        context.fetch(Person).filter {
            let e1: Expression<NSNumber> = $0.age - 1
            XCTAssertEqual(e1.name(), "from_age_subtract_1", "Pass")
            XCTAssertEqual(e1.expression(), NSExpression(forFunction: "from:subtract:", arguments: [NSExpression(forKeyPath: "age"), NSExpression(forConstantValue: 1)]), "Pass")
            let e2: Expression<NSNumber> = $0.age - $0.age
            XCTAssertEqual(e2.name(), "from_age_subtract_age", "Pass")
            XCTAssertEqual(e2.expression(), NSExpression(forFunction: "from:subtract:", arguments: [NSExpression(forKeyPath: "age"), NSExpression(forKeyPath: "age")]), "Pass")
            return e1 < e2
        }.execute()
    }
    
    func testMultiple() {
        context.fetch(Person).filter {
            let e1: Expression<NSNumber> = $0.age * 1
            XCTAssertEqual(e1.name(), "multiply_age_by_1", "Pass")
            XCTAssertEqual(e1.expression(), NSExpression(forFunction: "multiply:by:", arguments: [NSExpression(forKeyPath: "age"), NSExpression(forConstantValue: 1)]), "Pass")
            let e2: Expression<NSNumber> = $0.age * $0.age
            XCTAssertEqual(e2.name(), "multiply_age_by_age", "Pass")
            XCTAssertEqual(e2.expression(), NSExpression(forFunction: "multiply:by:", arguments: [NSExpression(forKeyPath: "age"), NSExpression(forKeyPath: "age")]), "Pass")
            return e1 < e2
        }.execute()
    }
    
    func testDivide() {
        context.fetch(Person).filter {
            let e1: Expression<NSNumber> = $0.age / 1
            XCTAssertEqual(e1.name(), "divide_age_by_1", "Pass")
            XCTAssertEqual(e1.expression(), NSExpression(forFunction: "divide:by:", arguments: [NSExpression(forKeyPath: "age"), NSExpression(forConstantValue: 1)]), "Pass")
            let e2: Expression<NSNumber> = $0.age / $0.age
            XCTAssertEqual(e2.name(), "divide_age_by_age", "Pass")
            XCTAssertEqual(e2.expression(), NSExpression(forFunction: "divide:by:", arguments: [NSExpression(forKeyPath: "age"), NSExpression(forKeyPath: "age")]), "Pass")
            return e1 < e2
        }.execute()
    }
    
    func testComplex() {
        context.fetch(Person).filter {
            let e1: Expression<NSNumber> = $0.age + 1 * 2
            XCTAssertEqual(e1.name(), "add_age_to_multiply_1_by_2", "Pass")
            XCTAssertEqual(e1.expression(), NSExpression(forFunction: "add:to:", arguments: [NSExpression(forKeyPath: "age"), NSExpression(forFunction: "multiply:by:", arguments: [NSExpression(forConstantValue: 1), NSExpression(forConstantValue: 2)])]), "Pass")
            let e2: Expression<NSNumber> = $0.age * 1 + 2
            XCTAssertEqual(e2.name(), "add_multiply_age_by_1_to_2", "Pass")
            XCTAssertEqual(e2.expression(), NSExpression(forFunction: "add:to:", arguments: [NSExpression(forFunction: "multiply:by:", arguments: [NSExpression(forKeyPath: "age"), NSExpression(forConstantValue: 1)]), NSExpression(forConstantValue: 2)]), "Pass")
            let e3: Expression<NSNumber> = ($0.age + 1) * 2
            XCTAssertEqual(e3.name(), "multiply_add_age_to_1_by_2", "Pass")
            XCTAssertEqual(e3.expression(), NSExpression(forFunction: "multiply:by:", arguments: [NSExpression(forFunction: "add:to:", arguments: [NSExpression(forKeyPath: "age"), NSExpression(forConstantValue: 1)]), NSExpression(forConstantValue: 2)]), "Pass")
            return e1 < e2
        }.execute()
    }
}
