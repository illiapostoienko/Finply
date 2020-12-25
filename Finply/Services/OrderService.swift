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
    func changeOrder<T>(from fromOrder: Int, to toOrder: Int, in models: [T]) -> [T] where T: OrderableType
    func deleteOrder<T>(at order: Int, in models: [T]) -> [T] where T: OrderableType
}

final class OrderService: OrderServiceType {
    
    deinit {
        print("deinit OrderService")
    }
    
    func createLastOrder(in models: [OrderableType]) -> Int {
        models.count
    }
    
    func changeOrder<T>(from fromOrder: Int, to toOrder: Int, in models: [T]) -> [T] where T: OrderableType {
        
        if fromOrder == toOrder { return [] }
        
        var modelsToUpdate = [T]()
        let orderToModelDict = models.toDictionary(with: { $0.order })
        
        orderToModelDict[fromOrder]
            .map{
                $0.updateOrder(to: toOrder)
                modelsToUpdate.append($0)
            }

        if fromOrder < toOrder {
            for order in (fromOrder + 1)...toOrder {
                orderToModelDict[order].map{
                    $0.updateOrder(to: order - 1)
                    modelsToUpdate.append($0)
                }
            }
        } else {
            for order in toOrder..<fromOrder {
                orderToModelDict[order].map{
                    $0.updateOrder(to: order + 1)
                    modelsToUpdate.append($0)
                }
            }
        }
        
        return modelsToUpdate
    }
    
    func deleteOrder<T>(at order: Int, in models: [T]) -> [T] where T: OrderableType {
        models
            .filter{ $0.order > order }
            .map{
                $0.updateOrder(to: $0.order - 1)
                return $0
            }
    }
}
