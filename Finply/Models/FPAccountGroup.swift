//
//  FPAccountGroup.swift
//  Finply
//
//  Created by Illia Postoienko on 30.09.2020.
//

import Foundation

struct FPAccountGroup {
    let id: UUID
    
    let name: String
    let order: Int
    let accountIds: [UUID]
    
    //TODO: Icons
    //public let color
    //public let icon
}
