//
//  OrderService.swift
//  Finply
//
//  Created by Illia Postoienko on 23.12.2020.
//

import Foundation

protocol OrderableType {
    var order: Int { get }
    
    func updateOrder(to order: Int)
}

protocol OrderServiceType {
    func createLastOrder(in models: [OrderableType]) -> Int
    func changeOrder<T>(from fromOrder: Int, to toOrder: Int, in models: [T]) where T: OrderableType
    func deleteOrder<T>(at order: Int, in models: [T]) where T: OrderableType
}

final class OrderService: OrderServiceType {
    
    deinit {
        print("deinit OrderService")
    }
    
    func createLastOrder(in models: [OrderableType]) -> Int {
        models.count
    }
    
    func changeOrder<T>(from fromOrder: Int, to toOrder: Int, in models: [T]) where T: OrderableType {
        guard fromOrder != toOrder else { return }
        
        let orderToModelDict = models.toDictionary(with: { $0.order })
        
        orderToModelDict[fromOrder]
            .map{
                $0.updateOrder(to: toOrder)
            }

        if fromOrder < toOrder {
            for order in (fromOrder + 1)...toOrder {
                orderToModelDict[order].map{
                    $0.updateOrder(to: order - 1)
                }
            }
        } else {
            for order in toOrder..<fromOrder {
                orderToModelDict[order].map{
                    $0.updateOrder(to: order + 1)
                }
            }
        }
    }
    
    func deleteOrder<T>(at order: Int, in models: [T]) where T: OrderableType {
        var modelsToUpdate = models
        
        modelsToUpdate
            .filter{ $0.order > order }
            .map{
                $0.updateOrder(to: $0.order - 1)
            }
    }
}
