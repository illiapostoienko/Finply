//
//  AddEditOperationViewModel.swift
//  Finply
//
//  Created by Illia Postoienko on 30.09.2020.
//

import RxSwift
import RxCocoa

protocol AddEditOperationViewModelType {
    
    var cancelTapped: PublishSubject<Void> { get }
    var operationAdded: Observable<FPOperation> { get }
    var operationEdited: Observable<FPOperation> { get }
}

final class AddEditOperationViewModel: AddEditOperationViewModelType {
        
    let operationService: FPOperationServiceType
    
    var cancelTapped = PublishSubject<Void>()
    var operationAdded: Observable<FPOperation> = PublishSubject<FPOperation>()
    var operationEdited: Observable<FPOperation> = PublishSubject<FPOperation>()
    
    init(operationService: FPOperationServiceType) {
        self.operationService = operationService
    }
}
