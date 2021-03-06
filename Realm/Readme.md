Barrel_Realm
=================

Barrel's Extension in Realm

## Feature
Type-safe fetch and insert.
```swift
var person = Person.insert(self.realm)
var results = Person.objects(self.realm)
```

Plese write AttributeType extensions.
```swift
extension AttributeType where ValueType: Person {
    var name: Attribute<String> { return attribute() }
    var age: Attribute<Int> { return attribute() }
}
```

## Extension of RealmCollectionType

If you use Barrel's function, use brl_* methods instead of common methods.
```swfit
var searchPersons = Person.objects(self.context)
                        .brl_filter { $0.name.beginsWith("A") }
                        .brl_sorted { $0.age < $1.age }
```

## Relationships
Your model has many-relationships, use List type in Attribute.
If your model has inverse-relationships, use LinkingObjects type in Attribute.
```swift
extension AttributeType where ValueType: Person {
    var name: Attribute<String> { return attribute() }
    var children: Attribute<List<Satellite>> { return attribute() }
    var parents: Attribute<LinkingObjects<Satellite>> { return attribute() }
}
