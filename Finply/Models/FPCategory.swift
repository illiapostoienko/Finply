//
//  FPCategory.swift
//  Finply
//
//  Created by Illia Postoienko on 30.09.2020.
//

import Foundation

struct FPCategory {
    let id: UUID

    let parentCategoryId: UUID
    let name: String
    let flow: CategoryFlow
    let order: Int
    
    //TODO: Icons
    //public let color
    //public let icon
    
    enum CategoryFlow {
        case income
        case expense
    }
}
