# IndexedStorage

[![Swift][swift-badge]][swift-url]
[![License][mit-badge]][mit-url]
<!-- [![Build Status][travis-badge]][travis-url] -->

A wrapper around Swifts Dictionary type that creates and maintains multiple indices for stored _Structs_. You should **not use it with classes**, because properties may change without the class noticing.


## Install

This library should be installable via SwiftPM, Carthage and CocoaPods.


## Example

Let's say you have a struct that looks like this:

```swift
struct Ship {
    let id: String
    let name: String
    let captain: String
}
```


### 1. Define Your Data Storage Subclass

To create a storage class by subclassing you need to define the `Element` type (`Ship`)
and the type of the `PrimaryKey` you wish to use to store your data. In this case `String`,
because we want `ship.id` to be the primary key. This key should be unique and `Hashable`.

```swift
class ShipData: IndexedStorage<Ship, String> {
}
```

### 2. Override Index Function

Our goal is to use `ship.id` as key for the primary index. Next, we want to maintain
two additional indices for `ship.name` and `ship.captain`.

To achieve that, we need to override three functions:

#### 2.1. Primary Key Access For The Primary Index

```swift
override class func primaryKey(for element: Ship) -> String {
    return element.id
}
```

#### 2.2. Number Of Additional Indices

"2" for `ship.name` and `ship.captain`.

```swift
override class func numberOfIndices() -> Int {
    return 2
}
```

#### 2.3. Hashes For The Additional Indices

By returning hashes for `ship.name` and `ship.captain` we provide all the information
needed to build the additional indices. Make sure the array length equals the number
returned by `numberOfIndices`. Otherwise the class will crash.

```swift
override class func hashValues(for element: Ship) -> [Int] {
    return [element.name.hashValue, element.captain.hashValue]
}
```

### 3. Create Convenience Accessors

You can now access structs using the additional indices by calling `indexedStorage.elements(for: name, onIndex: 0)`.
But it is more convenient to provide custom subscript functions like:

```swift
subscript(name name: String) -> [Ship] {
    return elements(for: name, onIndex: 0)
}

subscript(captain captain: String) -> [Ship] {
    return elements(for: captain, onIndex: 1)
}
```


### 4. The Final Class

```swift
class ShipData: IndexedStorage<Ship, String> {

    override class func primaryKey(for element: Ship) -> String {
        return element.id
    }

    override class func numberOfIndices() -> Int {
        return 2
    }

    override class func hashValues(for element: Ship) -> [Int] {
        return [element.name.hashValue, element.captain.hashValue]
    }

    subscript(name name: String) -> [Ship] {
        return elements(for: name, onIndex: 0)
    }

    subscript(captain captain: String) -> [Ship] {
        return elements(for: captain, onIndex: 1)
    }
}
```


## Usage

You can now access like this:

```swift
// Add
let enterprisePike = Ship(id: "USS-1701", name: "Enterprise", captain: "Christopher Pike")
shipData.add(enterprisePike)

let enterpriseD = Ship(id: "USS-1701-D", name: "Enterprise", captain: "Jean-Luc Picard")
shipData.add(enterpriseD)

// Update
let enterpriseKirk = Ship(id: "USS-1701", name: "Enterprise", captain: "James T. Kirk")
shipData.add(enterpriseKirk) // `enterprisePike` will be replaced because of the same `id`.

// Access
shipData["USS-1701"]
// => Ship(id: "USS-1701", name: "Enterprise", captain: "James T. Kirk")

shipData[name: "Enterprise"]
// => [Ship(id: "USS-1701", name: "Enterprise", captain: "James T. Kirk"), Ship(id: "USS-1701-D", name: "Enterprise", captain: "Jean-Luc Picard")]

shipData[captain: "James T. Kirk"]
// => [Ship(id: "USS-1701", name: "Enterprise", captain: "James T. Kirk")]

// Remove
shipData.remove(enterprise)

// Remove By Primary Key
shipData.remove(key: "USS-1701")
```

## License

This project is released under the MIT license. See [LICENSE](LICENSE) for details.


[swift-badge]: https://img.shields.io/badge/Swift-3.1-orange.svg?style=flat
[swift-url]: https://swift.org
[mit-badge]: https://img.shields.io/badge/License-MIT-blue.svg?style=flat
[mit-url]: https://tldrlegal.com/license/mit-license
<!-- [travis-badge]: https://travis-ci.org/uberbruns/CasingTools.svg?branch=master
[travis-url]: https://travis-ci.org/uberbruns/CasingTools -->
