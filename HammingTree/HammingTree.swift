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

internal class NodeToVisit<T: HammingHashable> {
    let node: HammingNode<T>
    let maxDistance: Int
    var next: NodeToVisit<T>? = nil
    
    init(node: HammingNode<T>, maxDistance: Int) {
        self.node = node
        self.maxDistance = maxDistance
    }
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
    
    func findClosest(point: T, maxDistance: Int) -> [T] {
        var results: [T] = []
        node.findClosest(&results, point: point, maxDistance: maxDistance)
        return results
    }
    
    func findClosestNonRecursive(point: T, maxDistance: Int) -> [T] {
        var results: [T] = []
        
        var nodeToVisit: NodeToVisit<T>! = NodeToVisit(node: self.node, maxDistance: maxDistance)
        var lastNode: NodeToVisit<T> = nodeToVisit
        
        var maxDistance: Int
        var distance: Int
        var node: HammingNode<T>
        var depth: UInt64
        var hash: UInt64
        var leftDecrement: Int
        var rightDecrement: Int
        var newNode: NodeToVisit<T>
        
        while nodeToVisit != nil {
            maxDistance = nodeToVisit.maxDistance
            if maxDistance < 0 {
                nodeToVisit = nodeToVisit.next
                continue
            }
            
            node = nodeToVisit.node
            depth = node.depth
            if node.isLeaf {
                hash = point.hammingHash
                for element in node.elements {
                    if (element === point) {
                        continue
                    }
                    
                    distance = hammingWeight((hash^element.hammingHash) >> depth)
                    
                    if distance <= maxDistance {
                        results.append(element);
                    }
                }
            } else {
                let result = (point.hammingHash >> depth) & 0b1
                
                if result == 0b1 {
                    leftDecrement = 1
                    rightDecrement = 0
                } else {
                    leftDecrement = 0
                    rightDecrement = 1
                }
                
                if maxDistance - leftDecrement >= 0 {
                    lastNode.next = NodeToVisit<T>(node: node.left, maxDistance: maxDistance - leftDecrement)
                    lastNode = lastNode.next!
                }
                if maxDistance - rightDecrement >= 0 {
                    lastNode.next = NodeToVisit<T>(node: node.right, maxDistance: maxDistance - rightDecrement)
                    lastNode = lastNode.next!
                }
            }
            
            nodeToVisit = nodeToVisit.next
        }
        
        return results
    }
}
