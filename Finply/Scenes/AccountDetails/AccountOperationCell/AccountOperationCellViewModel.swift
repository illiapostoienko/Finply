//
//  AccountOperationCellViewModel.swift
//  Finply
//
//  Created by Illia Postoienko on 06.11.2020.
//

import Foundation

protocol AccountOperationCellViewModelType {
    
    var operationId: UUID { get }
}

final class AccountOperationCellViewModel: AccountOperationCellViewModelType {
    
    let operationId: UUID = UUID()
}
