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

        // Main Pages
        container.register{ AccountDetailsViewModel(userStateService: $0) }.implements(AccountDetailsViewModelType.self)
        container.register{ BudgetsListViewModel() }.implements(BudgetsListViewModelType.self)
        container.register{ PlanningListViewModel() }.implements(PlanningListViewModelType.self)
        
        // Main Branches
        container.register{ AddEditOperationViewModel() }.implements(AddEditOperationViewModelType.self)
        container.register{ AccountsListViewModel(accountsService: $0, orderService: $1) }.implements(AccountsListViewModelType.self)
        container.register{ ReportDetailsViewModel() }.implements(ReportDetailsViewModelType.self)
        container.register{ AddEditAccountViewModel(accountsService: $0, accountsRepository: $1) }.implements(AddEditAccountViewModelType.self)
        container.register{ ProfileDetailsViewModel() }.implements(ProfileDetailsViewModelType.self)
        
        // Secondary Modules
        container.register{ AccountHeaderViewModel() }.implements(AccountHeaderViewModelType.self)
        container.register{ AccountMonthDetailsViewModel() }.implements(AccountMonthDetailsViewModelType.self)
        container.register{ CurrencyListViewModel() }.implements(CurrencyListViewModelType.self)
        container.register{ ColorSetsListViewModel() }.implements(ColorSetsListViewModelType.self)
        container.register{ IconsListViewModel() }.implements(IconsListViewModelType.self)
    }
    
    static func registerCoreServices(container: DependencyContainer) {

        container.register{ UserStateService(repository: $0) }.implements(UserStateServiceType.self)
        container.register{ OrderService() }.implements(OrderServiceType.self)
        container.register{ AccountsService(repository: $0, orderService: $1) }.implements(AccountsServiceType.self)
        
        container.register{ AccountsRepository() }.implements(AccountsRepositoryType.self)
    }
}
