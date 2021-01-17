//
//  Throttler.swift
//  Finply
//
//  Created by Illia Postoienko on 17.01.2021.
//

import Foundation

final class Throttler {
    
    private var dispatchWorkItem: DispatchWorkItem = DispatchWorkItem(block: {})
    private let dispatchQueue: DispatchQueue
    private var previousRun: Date = Date.distantPast
    private let scheduledDelay: Double
    
    init(scheduledDelay: Double, queue: DispatchQueue = DispatchQueue.main) {
        self.scheduledDelay = scheduledDelay
        self.dispatchQueue = queue
    }
    
    func throttle(_ block: @escaping () -> Void) {
        dispatchWorkItem.cancel()
        
        dispatchWorkItem = DispatchWorkItem() { [weak self] in
            self?.previousRun = Date()
            block()
        }
        
        let delay = previousRun.timeIntervalSinceNow > scheduledDelay ? 0 : scheduledDelay
        dispatchQueue.asyncAfter(deadline: .now() + delay, execute: dispatchWorkItem)
    }
}
