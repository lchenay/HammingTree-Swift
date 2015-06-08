//
//  HammingNode.swift
//  HammingTree
//
//  Created by Laurent CHENAY on 08/06/2015.
//  Copyright (c) 2015 Sunday. All rights reserved.
//

import Foundation

let m1: UInt64  = 0x5555555555555555; //binary: 0101...
let m2: UInt64  = 0x3333333333333333; //binary: 00110011..
let m4: UInt64  = 0x0f0f0f0f0f0f0f0f; //binary:  4 zeros,  4 ones ...
let m8: UInt64  = 0x00ff00ff00ff00ff; //binary:  8 zeros,  8 ones ...
let m16: UInt64 = 0x0000ffff0000ffff; //binary: 16 zeros, 16 ones ...
let m32: UInt64 = 0x00000000ffffffff; //binary: 32 zeros, 32 ones
let hff: UInt64 = 0xffffffffffffffff; //binary: all ones
let h01:UInt64 = 0x0101010101010101; //the sum of 256 to the power of 0,1,2,3...

//This methods make EXEC_BAD_INSTRUCTION
//Can't use it
func hammingWeight2(i: UInt64) -> Int {
    var x = i
    x -= (x >> 1) & m1;             //put count of each 2 bits into those 2 bits
    x = (x & m2) + ((x >> 2) & m2); //put count of each 4 bits into those 4 bits
    x = (x + (x >> 4)) & m4;        //put count of each 8 bits into those 8 bits
    x = (x * h01)>>56;  //returns left 8 bits of x + (x<<8) + (x<<16) + (x<<24) + ...
    return Int(x)
}

//__builtin_popcount is not accessible in Swift
//Can't use it
/*func hammingWeight3(var x: UInt64) -> Int {
    __builtin_popcount(x)
}*/

//Very slow implementation of bitCount
func hammingWeight(var x: UInt64) -> Int {
    var count: Int
    for (count = 0; x != 0; count++) {
        x &= x-1;
    }
    
    return count;
}

class HammingNode<T: HammingHashable> {
    var depth: UInt64
    var elements: [T] = []
    var left: HammingNode?
    var right: HammingNode?
    
    var isLeaf: Bool = true
    convenience init(items: [T]) {
        self.init()
        addItems(items)
    }
    
    init() {
        self.depth = 0
    }
    
    init(depth: Int) {
        self.depth = UInt64(depth)
    }
    
    init(depth: UInt64) {
        self.depth = depth
    }
    
    func addItem(item: T) {
        if isLeaf {
            elements.append(item)
            if elements.count > 1 {
                isLeaf = false
                left = HammingNode(depth: depth + 1)
                right = HammingNode(depth: depth + 1)
                addItems(elements)
                elements = []
            }
        } else {
            let result = (item.hash >> depth) & 0b1
            if result == 0b1 {
                right!.addItem(item)
            } else {
                left!.addItem(item)
            }
        }
    }
    
    func addItems(items: [T]) {
        for item in items {
            addItem(item)
        }
    }
    
    func findClosest(point: T, maxDistance: Int) -> [T] {
        if maxDistance < 0 {
            return []
        }
        
        if isLeaf {
            var results: [T] = []
            for element in elements {
                if (element === point) {
                    continue
                }
                let distance = hammingWeight((element.hash^point.hash) >> self.depth)
                if distance <= maxDistance {
                    results.append(element);
                }
            }
            
            return results
        } else {
            let result = (point.hash >> depth) & 0b1
            let leftDecrement: Int
            let rightDecrement: Int
            if result == 0b1 {
                leftDecrement = 1
                rightDecrement = 0
            } else {
                leftDecrement = 0
                rightDecrement = 1
            }
            
            let leftResult = left!.findClosest(point, maxDistance: maxDistance - leftDecrement)
            let rightResult = right!.findClosest(point, maxDistance: maxDistance - rightDecrement)
            
            if leftResult.count == 0 {
                return rightResult
            }
            if rightResult.count == 0 {
                return leftResult
            }
            var results: [T] = []
            results.extend(leftResult)
            results.extend(rightResult)
            return results;
        }
    }
}
