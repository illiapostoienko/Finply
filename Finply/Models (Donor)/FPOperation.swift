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
    let flow: OperationKind
    
    let valueInCents: Int
    let creationDate: Date
    let operationDate: Date
    let comment: String?
    //let photoPath: String?
    //let tagIds: [String]
    
    enum OperationKind {
        case noneIncome
        case noneExpense
        case categoryIncome(categoryId: UUID)
        case categoryExpense(categoryId: UUID)
        case accountIncome(fromAccountId: UUID)
        case accountExpense(toAccountId: UUID)
    }
}
