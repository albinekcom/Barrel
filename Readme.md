Barrel
=================

A simple type-safe library for NSPredicate and NSExpresion.

##Installation

You can use Carthage to install Barrel by adding it to your Cartfile:

```ogdl
github "tarunon/Barrel"
```

##Summary

Extend your class/struct A and AttributeType like.
```swift
class A: SelfExpression {
    var text: String
    var number: Int
    var option: String?
}

extension AttributeType where FieldType: A {
    var text: Attribute<String> { return storedAttribute(parent: self) }
    var number: Attribute<Int> { return storedAttribute(parent: self) }
    var option: OptionalAttribute<String> { return storedAttribute(parent: self) }
}
```

Make NSPredicate and NSExpression from Attribute<A>.
```swift
var attribute: Attribute<A> = storedAttribute()
var predicate: Predicate = (attribute.text == "TEXT") // predicate.value is NSPredicate
var expression: Expression = attribute.number.max() // expression.value is NSExpression
```

## Attribute

Extend AttributeType using computed property one by one FieldType.
Computed properties are Attribute<T>, or OptionalAttribute<T> and return "storedAttribute(parent: self)".
Get Attribute instance from "storedAttribute()".

## Expression

Make Expression by AttributeType.
If AttributeType's ValueType like Number, you can use max, min, sum, average, or +, -, /, * with other Attribute or Number.
Make kyepath expression using unwrapExpression.
```swift
var maxExpression: Expression = attribute.number.max()
var plus1Expression: Expression = (attribute.number + 1)
var keyPathExpression: Expression = unwrapExpression(attribute.text)
```

## Predicate

Make Predicate by AttributeType
Support operand (==, !=, <, <=, >=, >, <<)
Operand "<<" means in array or between range.
If AttributeType's ValueType is String, you can use contains, beginsWith, endsWith, maches method.
If AttributeType's ValueType like many-relationships, you can use any, all method by make struct extend ManyType.
```swift
var equalToPredicate: Predicate = (attribute.text == "TEST")
var containsPredicate: Predicate = attribute.text.contains("A")

struct Many<T: ExpressionType>: ManyType {
    typealias ValueType = [T]
    typealias ElementType = T
}

extension AttributeType where FieldType == A {
    var array: Attribute<Many<A>> { return storedAttribute(parent: self) }
}

var anyPredicate: Predicate = attribute.array.any { $0.number > 0 }
```

## SortDescriptors

Make SortDescriptors by AttributeType
```swift
var ascending: SortDescriptors = (attribute.number < attribute.number)
```

## Support Types
Barrel Support types listed
String, Int, Double, Float, Bool, Int16, Int32, Int64, Array, Dictionary, Set, NSDate, NSData, NSNumber
If you needs support more type, plese implement SelfExpression.
```swift
extension Type: SelfExpression {}
```
## LISENSE
MIT