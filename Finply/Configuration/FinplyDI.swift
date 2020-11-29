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

        //Main Pages
        container.register{ AccountDetailsViewModel(userStateService: $0) }.implements(AccountDetailsViewModelType.self)
        container.register{ BudgetsListViewModel() }.implements(BudgetsListViewModelType.self)
        container.register{ PlanningListViewModel() }.implements(PlanningListViewModelType.self)
        
        //Main Branches
        container.register{ AddEditOperationViewModel(operationService: $0) }.implements(AddEditOperationViewModelType.self)
        container.register{ AccountsListViewModel() }.implements(AccountsListViewModelType.self)
        container.register{ ReportDetailsViewModel() }.implements(ReportDetailsViewModelType.self)
        container.register{ AddEditAccountViewModel() }.implements(AddEditAccountViewModelType.self)
        container.register{ ProfileDetailsViewModel() }.implements(ProfileDetailsViewModelType.self)
        
        //Secondary Modules
        container.register{ AccountHeaderViewModel() }.implements(AccountHeaderViewModelType.self)
        container.register{ AccountMonthDetailsViewModel() }.implements(AccountMonthDetailsViewModelType.self)
        
    }
    
    static func registerCoreServices(container: DependencyContainer) {
        container.register{ FPAccountService() }.implements(FPAccountServiceType.self)
        container.register{ FPOperationService() }.implements(FPOperationServiceType.self)
        container.register{ UserStateService() }.implements(UserStateServiceType.self)
    }
    
    static func registerPersistence(container: DependencyContainer) {
        
    }
}
