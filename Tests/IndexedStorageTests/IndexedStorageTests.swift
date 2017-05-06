//
//  IndexedStorageTests.swift
//  IndexedStorage
//
//  Created by Karsten Bruns on {TODAY}.
//  Copyright © 2017 IndexedStorage. All rights reserved.
//

import Foundation
import XCTest
import IndexedStorage


struct Ship {
    let id: String
    let name: String
    let captain: String
}



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


struct Number {
    let value: Int
    let mod: Int
}



class NumberData: IndexedStorage<Number, Int> {

    override class func primaryKey(for element: Number) -> Int {
        return element.value
    }


    override class func numberOfIndices() -> Int {
        return 1
    }


    override class func hashValues(for element: Number) -> [Int] {
        return [element.mod.hashValue]
    }


    subscript(mod mod: Int) -> [Number] {
        return elements(for: mod, onIndex: 0)
    }
}


class IndexedStorageTests: XCTestCase {

    // Sample Data
    let enterprise = Ship(id: "USS-1701", name: "Enterprise", captain: "James T. Kirk")
    let mirrorEnterprise = Ship(id: "USS-1701", name: "Enterprise", captain: "James T. Kirk (Evil)")
    let enterpriseD = Ship(id: "USS-1701-D", name: "Enterprise", captain: "Jean-Luc Picard")
    let defiant = Ship(id: "NX-74205", name: "Defiant", captain: "Benjamin Sisko")
    let voyager = Ship(id: "USS-74656", name: "Voyager", captain: "Kathrin Janeway")


    override func setUp() {
        super.setUp()
    }


    override func tearDown() {
        super.tearDown()
    }


    func makeShipData() -> ShipData {
        let shipData = ShipData()

        shipData.add(enterprise)
        shipData.add(enterpriseD)
        shipData.add(defiant)
        shipData.add(voyager)

        return shipData
    }


    func testPresence() {
        let data = makeShipData()

        XCTAssertEqual(data["USS-1701"]?.name, "Enterprise")
        XCTAssertEqual(data["USS-1701-D"]?.name, "Enterprise")
        XCTAssertEqual(data["NX-74205"]?.name, "Defiant")
        XCTAssertEqual(data["USS-74656"]?.name, "Voyager")

        XCTAssertEqual(data[name: "Enterprise"].count, 2)
        XCTAssertEqual(data[name: "Defiant"].count, 1)
        XCTAssertEqual(data[name: "Voyager"].count, 1)
    }


    func testNameIndex() {
        let data = makeShipData()

        var enterprises = data[name: "Enterprise"]
        var captains = enterprises.map({ $0.captain }).sorted(by: <)

        XCTAssertEqual(captains, ["James T. Kirk", "Jean-Luc Picard"])

        data.remove(key: "USS-1701")
        enterprises = data[name: "Enterprise"]
        captains = enterprises.map({ $0.captain }).sorted(by: <)

        XCTAssertEqual(captains, ["Jean-Luc Picard"])
    }


    func testRemoveByKey() {
        let data = makeShipData()

        data.remove(key: "USS-1701")
        data.remove(key: "NX-74205")
        data.remove(key: "USS-74656")

        XCTAssertNil(data["USS-1701"])
        XCTAssertNil(data["NX-74205"])
        XCTAssertNil(data["USS-74656"])

        XCTAssertNotNil(data["USS-1701-D"])
        XCTAssertEqual(data[name: "Enterprise"].first?.captain, "Jean-Luc Picard")
        XCTAssertEqual(data[name: "Enterprise"].last?.captain, "Jean-Luc Picard")
    }


    func testRemoveByElement() {
        let data = makeShipData()

        data.remove(enterprise)
        data.remove(defiant)
        data.remove(voyager)

        XCTAssertNil(data["USS-1701"])
        XCTAssertNil(data["NX-74205"])
        XCTAssertNil(data["USS-74656"])

        XCTAssertNotNil(data["USS-1701-D"])
        XCTAssertEqual(data[name: "Enterprise"].first?.captain, "Jean-Luc Picard")
        XCTAssertEqual(data[name: "Enterprise"].last?.captain, "Jean-Luc Picard")
    }


    func testReplaceElement() {
        let data = makeShipData()

        data.add(mirrorEnterprise)
        data.remove(key: "USS-1701-D")

        XCTAssertEqual(data["USS-1701"]?.captain, "James T. Kirk (Evil)")
        XCTAssertEqual(data[name: "Enterprise"].first?.captain, "James T. Kirk (Evil)")
        XCTAssertEqual(data[name: "Enterprise"].last?.captain, "James T. Kirk (Evil)")
    }


    func testBenchmark() {
        measure {
            let mod = 128
            let iterations = mod * mod

            let data = NumberData()

            // Add
            for i in 0..<iterations {
                let number = Number(value: i, mod: i % mod)
                data.add(number)
            }

            // Override
            for i in 0..<iterations {
                let number = Number(value: i, mod: i % mod)
                data.add(number)
            }
            
            // Access
            for i in 0..<mod {
                _ = data[mod: i]
            }
            
            // Remove
            for i in 0..<iterations {
                let number = data[i]
                data.remove(number!)
            }
        }
    }
}
