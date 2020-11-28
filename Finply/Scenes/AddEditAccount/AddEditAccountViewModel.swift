//  
//  AddEditAccountViewModel.swift
//  Finply
//
//  Created by Illia Postoienko on 10.11.2020.
//

import RxSwift
import RxCocoa

protocol AddEditAccountViewModelCoordination {
    var close: Observable<Void> { get }
    var accountComplete: Observable<FPAccount> { get }
}

protocol AddEditAccountViewModelType: BaseModalViewModelType {
    var coordination: AddEditAccountViewModelCoordination { get }
}

final class AddEditAccountViewModel: AddEditAccountViewModelType, AddEditAccountViewModelCoordination,
                                     BaseModalViewModelOutput, BaseModalViewModelInput
{
    var input: BaseModalViewModelInput { return self }
    var output: BaseModalViewModelOutput { return self }
    var coordination: AddEditAccountViewModelCoordination { return self }
    
    // Base Output
    var dataSource: Observable<[BaseModalTableViewItem]> { _dataSource.asObservable() }
    var title: String
    var isCheckButtonHidden: Bool = false
    
    // Base Input
    var closeButtonTap: AnyObserver<Void> { _closeTapStream.asObserver() }
    var checkButtonTap: AnyObserver<Void> { _checkButtonStream.asObserver() }
    var itemSelected: AnyObserver<Int> { _itemSelectedStream.asObserver() }
    
    // Coordination
    var close: Observable<Void> { _closeTapStream }
    var accountComplete: Observable<FPAccount> { _accountCompleteStream }
    
    // Locals
    private let _closeTapStream = PublishSubject<Void>()
    private let _checkButtonStream = PublishSubject<Void>()
    private let _itemSelectedStream = PublishSubject<Int>()
    private let _accountCompleteStream = PublishSubject<FPAccount>()
    
    private let _existingAccount: BehaviorRelay<FPAccount?>
    private let _dataSource = BehaviorRelay<[BaseModalTableViewItem]>(value: [])
    
    init(accountToEdit: FPAccount? = nil) {
        title = accountToEdit == nil ? "Add Account" : "Edit Account"
        
        _existingAccount = BehaviorRelay<FPAccount?>(value: accountToEdit)
        // create childs and fill with accountToEdit's values
        
        let completedAccount = _checkButtonStream
            .withLatestFrom(_existingAccount)
            .unwrap()
        
        // _checkButtonStream -> fill _completedAccount if everything is ok,
        // or show validation error if not
    }
}
