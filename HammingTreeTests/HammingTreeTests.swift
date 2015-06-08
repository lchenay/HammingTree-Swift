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
    public let hash: UInt64
    
    init(id: Int, hash: UInt64) {
        self.id = id
        self.hash = hash
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
        let tree = HammingTree<Photo>()
        let p1 = Photo(id: 1, hash: 0b0001)
        let p2 = Photo(id: 2, hash: 0b0011)
        let p3 = Photo(id: 3, hash: 0b1100)
        let p4 = Photo(id: 4, hash: 0b1111)
        let p5 = Photo(id: 5, hash: 0b0111)
        
        tree.addItem(p1)
        tree.addItem(p2)
        tree.addItem(p3)
        tree.addItem(p4)
        tree.addItem(p5)
        
        //let result1 = tree.findClosest(p1, maxDistance: 0)
        //XCTAssertEqual(result1.count, 0)
        
        let result2 = tree.findClosest(p1, maxDistance: 1)
        XCTAssertEqual(result2.count, 1)
        XCTAssertEqual(result2[0], p2)
        
        let result3 = tree.findClosest(p4, maxDistance: 2)
        XCTAssertEqual(result3.count, 3)
        XCTAssertTrue(find(result3, p2) != nil)
        XCTAssertTrue(find(result3, p3) != nil)
        XCTAssertTrue(find(result3, p5) != nil)
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
            let tree = HammingTree<Photo>()
            
            for (var i = 0 ; i < 25000 ; i++) {
                let point = Photo(id: i, hash: random64())
                tree.addItem(point)
                tree.findClosest(point, maxDistance: 2).count
            }
            
        }
    }
}
