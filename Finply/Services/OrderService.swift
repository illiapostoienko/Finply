//
//  OrderService.swift
//  Finply
//
//  Created by Illia Postoienko on 23.12.2020.
//

import Foundation

protocol OrderableType {
    var order: Int { get }
    
    mutating func updateOrder(to order: Int)
}

protocol OrderServiceType {
    func createLastOrder(in models: [OrderableType]) -> Int
    func changeOrder<T>(from fromOrder: Int, to toOrder: Int, in models: [T]) -> [T] where T: OrderableType
    func deleteOrder<T>(at order: Int, in models: [T]) -> [T] where T: OrderableType
}

final class OrderService: OrderServiceType {
    
    func createLastOrder(in models: [OrderableType]) -> Int {
        models.count
    }
    
    func changeOrder<T>(from fromOrder: Int, to toOrder: Int, in models: [T]) -> [T] where T: OrderableType {
        
        if fromOrder == toOrder { return [] }
        
        var modelsToUpdate = [T]()
        let orderToModelDict = models.toDictionary(with: { $0.order })
        
        orderToModelDict[fromOrder]
            .map{
                var updatingModel = $0
                updatingModel.updateOrder(to: toOrder)
                modelsToUpdate.append(updatingModel)
            }

        if fromOrder < toOrder {
            for order in (fromOrder + 1)...toOrder {
                orderToModelDict[order].map{
                    var updatingModel = $0
                    updatingModel.updateOrder(to: order - 1)
                    modelsToUpdate.append(updatingModel)
                }
            }
        } else {
            for order in toOrder..<fromOrder {
                orderToModelDict[order].map{
                    var updatingModel = $0
                    updatingModel.updateOrder(to: order + 1)
                    modelsToUpdate.append(updatingModel)
                }
            }
        }
        
        return modelsToUpdate
    }
    
    func deleteOrder<T>(at order: Int, in models: [T]) -> [T] where T: OrderableType {
        models
            .filter{ $0.order > order }
            .map{
                var updatingModel = $0
                updatingModel.updateOrder(to: $0.order - 1)
                return updatingModel
            }
    }
}
