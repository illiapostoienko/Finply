//
//  OperationSectionDto.swift
//  Finply
//
//  Created by Illia Postoienko on 24.12.2020.
//

import Foundation

final class OperationSectionDto {
    
    let id: String
    let accountId: String
    var sectionDate: Date
    
    //operations
    
    let operationSectionModel: OperationSectionModel
    
    init(operationSectionModel: OperationSectionModel) {
        self.operationSectionModel = operationSectionModel
        
        self.id = operationSectionModel.id
        self.accountId = operationSectionModel.accountId
        self.sectionDate = operationSectionModel.sectionDate
    }
}
