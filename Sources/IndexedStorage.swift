//
//  IndexedStorage.swift
//  IndexedStorage
//
//  Created by Karsten Bruns on {TODAY}.
//  Copyright © 2017 IndexedStorage. All rights reserved.
//

import Foundation


/// Override this class to create a dictionary-like data storage, that
/// automatically creates and updates multiples indexes. As subclass you
/// need to overide three methods:
///
/// - `primaryKey(for element: Element)`
/// - `numberOfIndices()` and
/// - `hashValues(for element: Element)`
///
/// Read these methos descriptions to learn about the expected
/// return values.
///
/// You should also consider adding methods like this to your subclasses
/// to make the access of the indexed elements more convenient:
///
/// ```
/// subscript(name name: String) -> [User] {
///     return self[index: 0, value: name]
/// }
/// ```


open class IndexedStorage<Element, PrimaryKey: Hashable> {

    // MARK: Properties

    // Private Types
    private typealias InternalIndex = [Int: Set<PrimaryKey>]

    // Storage
    public private(set) var storage: [PrimaryKey: Element]

    // Indicies
    private var indices: [InternalIndex]
    private let indicesCount: Int
    private let primaryKey: (Element) -> PrimaryKey


    // MARK: Life-Cycle

    public init() {
        self.storage = [PrimaryKey: Element]()
        self.indicesCount = type(of: self).numberOfIndices()
        self.indices = Array(repeating: InternalIndex(), count: indicesCount)
        self.primaryKey = type(of: self).primaryKey(for:)
    }


    // MARK: Customization API

    /// `primaryKey` should return the main value, that the class should use
    /// to save and find your element. For example `element.id`.
    /// This method is called, when you `add` or `remove` an element.

    open class func primaryKey(for element: Element) -> PrimaryKey {
        fatalError("Implement " + #function)
    }


    /// Returns the number of indices, that this class should manage.
    /// This method only called during `init()`.

    open class func numberOfIndices() -> Int {
        fatalError("Implement " + #function)
    }


    /// Build an array that contains hash values for each index
    /// for the provided element and return it. For example:
    /// `return [element.name.hashValue, element.parent.hashValue]`

    open class func hashValues(for element: Element) -> [Int] {
        fatalError("Implement " + #function)
    }


    // MARK: Storage Access API

    /// Adds an element to the storage or updates an existing one.
    ///
    /// - Parameter element: The `Element` you wish to add or update.

    public func add(_ element: Element) {
        // Get Key
        let key = primaryKey(element)

        // Remove old data if needed
        remove(key: key)

        // Add element
        storage[key] = element

        // Index element
        let hashValues = type(of: self).hashValues(for: element)
        for i in 0..<indicesCount {
            let hash = hashValues[i]
            if indices[i][hash]?.insert(key) == nil {
                indices[i][hash] = Set([key])
            }
        }
    }


    /// Removes the provided element from the storage.
    /// This is a thin wrapper around `remove(key: PrimaryKey)`
    ///
    /// - Parameter element: The element you wish to remove.

    public func remove(_ element: Element) {
        let key = primaryKey(element)
        remove(key: key)
    }


    /// Removes the element for the provided key from the storage.
    ///
    /// - Parameter key: The primary key of the element you want to remove.
    /// - Returns: Returns the deleted element and nil if it was not found.

    @discardableResult
    public func remove(key: PrimaryKey) -> Element? {
        guard let removedElement = storage.removeValue(forKey: key) else {
            return nil
        }

        let hashValues = type(of: self).hashValues(for: removedElement)
        for i in 0..<indicesCount {
            let hash = hashValues[i]
            if indices[i][hash]?.remove(key) == nil {
                fatalError("Expected key did not exist in indexed storage")
            }
            if indices[i][hash]?.isEmpty == true {
                indices[i].removeValue(forKey: hash)
            }
        }
        return removedElement
    }


    /// Use this function to access elements on a specific index.
    ///
    /// You should also consider adding wrapper functions
    /// like this to your subclasses to make the access of the indexed
    /// elements more convenient:
    ///
    /// ```
    /// subscript(name name: String) -> [User] {
    ///     return elements(for: name, onIndex: 0)
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - index: The number of the index
    ///   - value: The value that the elements should share on the specified index.
    /// - Returns: Returns an array of elements sharing the specified value.

    public func elements(for value: AnyHashable, onIndex index: Int) -> [Element] {
        let hash = value.hashValue
        let primaryKeys = indices[index][hash] ?? []
        return primaryKeys.map({
            if let element = self.storage[$0] {
                return element
            } else {
                fatalError("Index points to element that does not exist")
            }
        })
    }


    /// Find out if there are any elements stored for a given value on a specific index.
    ///
    /// - Parameters:
    ///   - index: The number of the index
    ///   - value: The possibly indexed value
    /// - Returns: `true` if there are no elements for the provided value.

    public func elementsExists(for value: AnyHashable, onIndex index: Int) -> Bool {
        let hash = value.hashValue
        return !(indices[index][hash]?.isEmpty ?? true)
    }


    /// Gets you the number of elements for a given value on a specific index.
    ///
    /// - Parameters:
    ///   - value: he possibly indexed value
    ///   - index: The number of the index
    /// - Returns: The number of elements

    public func numberOfElements(for value: AnyHashable, onIndex index: Int) -> Int {
        let hash = value.hashValue
        return indices[index][hash]?.count ?? 0
    }


    /// Convenience subscript function to access elements using the primary key.
    /// Returns `nil` if no element is found and `remove`s an element when you call the
    /// setter with `nil`.
    ///
    /// - Parameter key: The primary key to access an element.
    /// - Returns: The element for the provided key.

    public subscript(key: PrimaryKey) -> Element? {
        get {
            return storage[key]
        }
        set(element) {
            if let element = element {
                add(element)
            } else {
                remove(key: key)
            }
        }
    }
}
