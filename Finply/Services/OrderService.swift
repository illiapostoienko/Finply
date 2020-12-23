//
//  OrderService.swift
//  Finply
//
//  Created by Illia Postoienko on 23.12.2020.
//

import Foundation

protocol OrderableType {
    var order: Int { get }
    
    func changeOrder(to order: Int)
}

protocol OrderServiceType {
    func createLastOrder(in models: [OrderableType]) -> Int
    func changeOrder(from fromOrder: Int, to toOrder: Int, in models: inout [OrderableType])
    func deleteOrder(at order: Int, in models: inout [OrderableType])
}

final class OrderService: OrderServiceType {
    
    func createLastOrder(in models: [OrderableType]) -> Int {
        models.count
    }
    
    func changeOrder(from fromOrder: Int, to toOrder: Int, in models: inout [OrderableType] ) {

        guard fromOrder != toOrder else { return }
        
        let orderToModelDict = models.toDictionary(with: { $0.order })
        
        orderToModelDict[fromOrder].map{ $0.changeOrder(to: toOrder) }

        if fromOrder < toOrder {
            for order in (fromOrder + 1)...toOrder {
                orderToModelDict[order].map{ $0.changeOrder(to: order - 1) }
            }
        } else {
            for order in toOrder..<fromOrder {
                orderToModelDict[order].map{ $0.changeOrder(to: order + 1) }
            }
        }
    }
    
    func deleteOrder(at order: Int, in models: inout [OrderableType]) {
        models.forEach{
            if $0.order > order {
                $0.changeOrder(to: $0.order - 1)
            }
        }
    }
}
