//
//  FPOperation.swift
//  Finply
//
//  Created by Illia Postoienko on 30.09.2020.
//

import Foundation

struct FPOperation {
    let id: UUID
    
    let accountId: UUID
    let flow: OperationFlow
    
    let value: Double
    let creationDate: Date
    let setDate: Date
    let comment: String?
    let photoPath: String?
    let tagIds: [String]
    
    enum OperationFlow {
        case noneIncome
        case noneExpense
        case categoryIncome(categoryId: UUID)
        case categoryExpense(categoryId: UUID)
        case accountIncome(fromAccountId: UUID)
        case accountExpense(toAccountId: UUID)
    }
}
