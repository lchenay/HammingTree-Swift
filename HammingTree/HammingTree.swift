//
//  HammingTree.swift
//  HammingTree
//
//  Created by Laurent CHENAY on 08/06/2015.
//  Copyright (c) 2015 Sunday. All rights reserved.
//

import Foundation

public protocol HammingHashable: AnyObject {
    var hash: UInt64 { get }
}

public class HammingTree<T: HammingHashable> {
    var node: HammingNode<T>
    
    init() {
        node = HammingNode()
    }
    
    convenience init(_ items: [T]) {
        self.init()
        addItems(items)
    }
    
    func addItem(item: T) {
        node.addItem(item)
    }
    
    func addItems(item: [T]) {
        node.addItems(item)
    }
    
    func findClosest(point: T, maxDistance: Int) -> [T] {
        return node.findClosest(point, maxDistance: maxDistance)
    }
}