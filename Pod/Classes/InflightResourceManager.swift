//
//  InflightResourcesManager.swift
//  Pods
//
//  Created by David Conner on 10/6/15.
//

let kInflightResourceCountDefault = 3 // three is magic number

public class InflightResourceManager {
    public var inflightResourceCount:Int
    public var index:Int = 0
    public var inflightResourceSemaphore:dispatch_semaphore_t
    
    init(inflightResourceCount: Int = kInflightResourceCountDefault) {
        self.inflightResourceCount = inflightResourceCount
        self.inflightResourceSemaphore = dispatch_semaphore_create(self.inflightResourceCount)
    }
    
    public func next() {
        dispatch_semaphore_signal(inflightResourceSemaphore)
        index = (index + 1) % inflightResourceCount
    }
    
    public func wait() {
        dispatch_semaphore_wait(inflightResourceSemaphore, DISPATCH_TIME_FOREVER)
    }
    
    deinit {
        for _ in 0...inflightResourceCount-1 {
            dispatch_semaphore_signal(inflightResourceSemaphore)
        }
    }
}
