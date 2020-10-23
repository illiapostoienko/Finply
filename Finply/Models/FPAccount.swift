//
//  FPAccount.swift
//  Finply
//
//  Created by Illia Postoienko on 30.09.2020.
//

import Foundation

struct FPAccount {
    let id: UUID
    
    let name: String
    let baseValue: Double
    let calculatedValue: Double
    let currency: String
    
    let order: Int
    
    //TODO: Icons
    //public let color
    //public let icon
}
