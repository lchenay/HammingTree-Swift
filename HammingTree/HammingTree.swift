//
//  HammingTree.swift
//  HammingTree
//
//  Created by Laurent CHENAY on 08/06/2015.
//  Copyright (c) 2015 Sunday. All rights reserved.
//

import Foundation

public protocol HammingHashable: AnyObject, Equatable {
    var hammingHash: UInt64 { get }
}

public class HammingTree<T: HammingHashable> {
    private var node: HammingNode<T>
    
    public init(maxElements: Int) {
        node = HammingNode(maxElements: maxElements)
    }
    
    public convenience init(_ items: [T]) {
        self.init(maxElements: 1)
        addItems(items)
    }
    
    public func addItem(item: T) {
        node.addItem(item)
    }
    
    public func addItems(item: [T]) {
        node.addItems(item)
    }
    
    public func findClosest(point: T, maxDistance: Int) -> [T] {
        var results: [T] = []
        
        node.findClosest(&results, point: point.hammingHash, maxDistance: maxDistance)
        
        if let index = results.indexOf(point) {
            results.removeAtIndex(index)
        }
        return results
    }
    
    public func findClosest(point: UInt64, maxDistance: Int) -> [T] {
        var results: [T] = []
        
        node.findClosest(&results, point: point, maxDistance: maxDistance)
        return results
    }
    
    typealias NodeToVisit = (node: HammingNode<T>, maxDistance: Int)
    
    public func findClosestNonRecursive(point: T, maxDistance: Int) -> [T] {
        var results: [T] = []
        
        var nodeToVisites: [NodeToVisit] = [(node: self.node, maxDistance: maxDistance)]
        
        var maxDistance: Int
        var distance: Int
        var node: HammingNode<T>
        var depth: UInt64
        var hash: UInt64
        var leftDecrement: Int
        var rightDecrement: Int
        var newNode: NodeToVisit
        var nodeToVisit: NodeToVisit
        for var i = 0 ; i < nodeToVisites.count ; i++ {
            nodeToVisit = nodeToVisites[i]
            maxDistance = nodeToVisit.maxDistance
            
            node = nodeToVisit.node
            depth = node.depth
            if node.isLeaf {
                hash = point.hammingHash
                for item in node.elements {
                    let element = item as! T
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
                    newNode = (node: node.left, maxDistance: maxDistance - leftDecrement)
                    nodeToVisites.append(newNode)
                }
                if maxDistance - rightDecrement >= 0 {
                    newNode = (node: node.left, maxDistance: maxDistance - rightDecrement)
                    nodeToVisites.append(newNode)
                }
            }
        }
        
        return results
    }
}
