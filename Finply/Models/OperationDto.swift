//
//  OperationDto.swift
//  Finply
//
//  Created by Illia Postoienko on 10.01.2021.
//

import Foundation

struct OperationDto: Equatable {
    
    let operationModel: OperationModel
    
    init(operationModel: OperationModel) {
        self.operationModel = operationModel
    }
}
