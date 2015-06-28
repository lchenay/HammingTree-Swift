//
//  HammingTreeTests.swift
//  HammingTreeTests
//
//  Created by Laurent CHENAY on 08/06/2015.
//  Copyright (c) 2015 Sunday. All rights reserved.
//

import UIKit
import XCTest

func random64() -> UInt64 {
    var rnd : UInt64 = 0
    arc4random_buf(&rnd, Int(sizeofValue(rnd)))
    return rnd
}

public func ==(left: Photo, right: Photo) -> Bool {
    return left.id == right.id
}

public class Photo: HammingHashable, Equatable {
    public let id: Int
    public let hammingHash: UInt64
    
    init(id: Int, hammingHash: UInt64) {
        self.id = id
        self.hammingHash = hammingHash
    }
}

class HammingTreeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTree() {
        let tree = HammingTree<Photo>(maxElements: 1)
        let p1 = Photo(id: 1, hammingHash: 0b0001)
        let p2 = Photo(id: 2, hammingHash: 0b0010)
        let p3 = Photo(id: 3, hammingHash: 0b0100)
        let p4 = Photo(id: 4, hammingHash: 0b1000)
        let p5 = Photo(id: 5, hammingHash: 0b0000)
        
        tree.addItem(p1)
        tree.addItem(p2)
        tree.addItem(p3)
        tree.addItem(p4)
        tree.addItem(p5)
        
        var result = tree.findClosest(p1, maxDistance: 1)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0], p5)
        
        result = tree.findClosest(p1, maxDistance: 4)
        
    }
    
    func testHammingWeight() {
        for (var i = 0 ; i < 1000000 ; i++) {
            let weight = random64()
            let result1 = hammingWeight(weight)
            let result2 = hammingWeight4(weight)
            XCTAssertEqual(result1, result2)
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            print("start")
            let tree = HammingTree<Photo>(maxElements: 5)
            
            for (var i = 0 ; i < 25000 ; i++) {
                let point = Photo(id: i, hammingHash: random64())
                tree.addItem(point)
                tree.findClosest(point, maxDistance: 2).count
            }
        }
    }
    
    func testPerformanceNonRecursiveExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            print("start")
            let tree = HammingTree<Photo>(maxElements: 5)
            
            for (var i = 0 ; i < 25000 ; i++) {
                let point = Photo(id: i, hammingHash: random64())
                tree.addItem(point)
                tree.findClosestNonRecursive(point, maxDistance: 2).count
            }
        }
    }
}
