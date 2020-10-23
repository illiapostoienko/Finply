//
//  FinplyDI.swift
//  Finply
//
//  Created by Illia Postoienko on 30.09.2020.
//

import Foundation
import Dip

final class FinplyDI {
 
    static func registerViewModels(container: DependencyContainer) {
        container.register{ HomeScreenViewModel(accountService: $0) }.implements(HomeScreenViewModelType.self)
        container.register{ AddEditOperationViewModel(operationService: $0) }.implements(AddEditOperationViewModelType.self)
        container.register{ AccountsListViewModel() }.implements(AccountsListViewModelType.self)
    }
    
    static func registerCoreServices(container: DependencyContainer) {
        container.register{ FPAccountService() }.implements(FPAccountServiceType.self)
        container.register{ FPOperationService() }.implements(FPOperationServiceType.self)
    }
    
    static func registerPersistence(container: DependencyContainer) {
        
    }
}
