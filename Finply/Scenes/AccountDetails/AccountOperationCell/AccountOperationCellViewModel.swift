//
//  AccountOperationCellViewModel.swift
//  Finply
//
//  Created by Illia Postoienko on 06.11.2020.
//

import Foundation

protocol AccountOperationCellViewModelType {
    
    var operation: FPOperation { get }
}

final class AccountOperationCellViewModel: AccountOperationCellViewModelType {
    
    let operation = FPOperation(id: UUID(), accountId: UUID(), flow: .noneIncome, value: 23.94, creationDate: Date(), comment: "Some comment", photoPath: nil, tagIds: [])
}
