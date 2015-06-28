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
    var x: UInt64 = i
    x -= (x >> 1) & m1;             //put count of each 2 bits into those 2 bits
    x = (x & m2) + ((x >> 2) & m2); //put count of each 4 bits into those 4 bits
    x = (x + (x >> 4)) & m4;        //put count of each 8 bits into those 8 bits
    x = (x * h01)>>24;  //returns left 8 bits of x + (x<<8) + (x<<16) + (x<<24) + ...
    return Int(x)
}

func hammingWeight(i: UInt64) -> Int {
    var x = i
    x -= (x >> 1) & m1;             //put count of each 2 bits into those 2 bits
    x = (x & m2) + ((x >> 2) & m2); //put count of each 4 bits into those 4 bits
    x = (x + (x >> 4)) & m4;        //put count of each 8 bits into those 8 bits
    x += x >>  8;  //put count of each 16 bits into their lowest 8 bits
    x += x >> 16;  //put count of each 32 bits into their lowest 8 bits
    x += x >> 32;  //put count of each 64 bits into their lowest 8 bits
    return Int(x & 0x7f);
}

//__builtin_popcount is not accessible in Swift
//Can't use it
/*func hammingWeight3(var x: UInt64) -> Int {
    __builtin_popcount(x)
}*/

//Very slow implementation of bitCount
func hammingWeight4(var x: UInt64) -> Int {
    var count: Int
    for (count = 0; x != 0; count++) {
        x &= x-1;
    }
    
    return count;
}

internal class HammingNode<T: HammingHashable> {
    internal let depth: UInt64
    internal var elements = NSSet()
    internal var left: HammingNode<T>!
    internal var right: HammingNode<T>!
    var maxElements = 1
    private let mask: UInt64
    
    internal var isLeaf: Bool = true
    convenience init(items: [T]) {
        self.init(maxElements: 1)
        addItems(items)
    }
    
    init(maxElements: Int) {
        self.depth = 0
        self.maxElements = maxElements
        self.mask = 0b1 << depth
    }
    
    convenience init(depth: Int) {
        self.init(depth: UInt64(depth), maxElements: 1)
    }
    
    init(depth: UInt64, maxElements: Int) {
        self.depth = depth
        self.maxElements = maxElements
        self.mask = 0b1 << depth
    }
    
    func addItem(item: T) {
        if isLeaf {
            if elements.count > maxElements && depth < 63 {
                isLeaf = false
                left = HammingNode(depth: depth + 1, maxElements: maxElements)
                right = HammingNode(depth: depth + 1, maxElements: maxElements)
                addItems(elements)
                addItem(item)
                elements = []
            } else {
                let newElements: NSMutableSet = elements.mutableCopy() as! NSMutableSet
                newElements.addObject(item)
                elements = newElements
            }
        } else {
            let result = (item.hammingHash & mask)
            if result == 0 {
                left.addItem(item)
            } else {
                right.addItem(item)
            }
        }
    }
    
    func addItems(items: [T]) {
        for item in items {
            addItem(item)
        }
    }
    
    func addItems(items: NSSet) {
        for item in items {
            addItem(item as! T)
        }
    }
    
    func findClosest(inout results: [T], point: UInt64, maxDistance: Int) {
        if isLeaf {
            let hash = point >> self.depth
            var distance: Int
            for item in elements {
                let element = item as! T
                distance = hammingWeight((hash^(element.hammingHash >> self.depth)))
                if distance <= maxDistance {
                    results.append(element);
                }
            }
            
            return
        } else {
            let leftMaxDistance: Int
            let rightMaxDistance: Int
            if (point & mask) == 0 {
                leftMaxDistance = maxDistance
                rightMaxDistance = maxDistance - 1
            } else {
                leftMaxDistance = maxDistance - 1
                rightMaxDistance = maxDistance
            }
            
            if leftMaxDistance >= 0 {
                left.findClosest(&results, point: point, maxDistance: leftMaxDistance)
            }
            if rightMaxDistance >= 0 {
                right.findClosest(&results, point: point, maxDistance: rightMaxDistance)
            }
        }
    }
}
