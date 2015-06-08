//
//  HammingTree.swift
//  HammingTree
//
//  Created by Laurent CHENAY on 08/06/2015.
//  Copyright (c) 2015 Sunday. All rights reserved.
//

import Foundation

public protocol HammingHashable: AnyObject {
    var hammingHash: UInt64 { get }
}

public class HammingTree<T: HammingHashable> {
    private var node: HammingNode<T>
    
    public init() {
        node = HammingNode()
    }
    
    public convenience init(_ items: [T]) {
        self.init()
        addItems(items)
    }
    
    public func addItem(item: T) {
        node.addItem(item)
    }
    
    public func addItems(item: [T]) {
        node.addItems(item)
    }
    
    //TODO: do a non recusrive findClosest to optimise performance and retain
    public func findClosest(point: T, maxDistance: Int) -> [T] {
        return node.findClosest(point, maxDistance: maxDistance)
    }
}