//
//  InflightResourcesManager.swift
//  Pods
//
//  Created by David Conner on 10/6/15.
//
//

let kInflightResourceCountDefault = 3

class InflightResourceManager {
    var inflightResourceCount:Int
    var inflightResourceIndex:Int = 0
    var inflightResourceSemaphore:dispatch_semaphore_t
    
    
    init(inflightResourceCount: Int = kInflightResourceCountDefault) {
        self.inflightResourceCount = inflightResourceCount
        self.inflightResourceSemaphore = dispatch_semaphore_create(self.inflightResourceCount)
    }
    
    func increment() {
        dispatch_semaphore_signal(inflightResourceSemaphore)
        inflightResourceIndex = (inflightResourceIndex + 1) % inflightResourceCount
    }
    
    func wait() {
        dispatch_semaphore_wait(inflightResourceSemaphore, DISPATCH_TIME_FOREVER)
    }
    
    deinit {
        for _ in 0...inflightResourceCount-1 {
            dispatch_semaphore_signal(inflightResourceSemaphore)
        }
    }
}
