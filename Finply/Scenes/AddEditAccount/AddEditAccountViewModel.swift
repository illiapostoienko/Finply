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
    var accountComplete: Observable<AccountModelType> { get }
}

protocol AddEditAccountViewModelType: BaseModalViewModelType {
    var coordination: AddEditAccountViewModelCoordination { get }
    
    func setupAccountToEdit(_ accountToEdit: AccountModelType)
}

final class AddEditAccountViewModel: AddEditAccountViewModelType, AddEditAccountViewModelCoordination,
                                     BaseModalViewModelOutput, BaseModalViewModelInput
{
    var input: BaseModalViewModelInput { return self }
    var output: BaseModalViewModelOutput { return self }
    var coordination: AddEditAccountViewModelCoordination { return self }
    
    // Base Output
    var dataSource: Observable<[BaseModalTableViewItem]> { _dataSource.asObservable() }
    var title: Driver<String> { _currentTitle.asDriver() }
    var isCheckButtonHidden: Bool = false
    
    // Base Input
    var closeButtonTap: AnyObserver<Void> { _closeTapStream.asObserver() }
    var checkButtonTap: AnyObserver<Void> { _checkButtonStream.asObserver() }
    var itemSelected: AnyObserver<Int> { _itemSelectedStream.asObserver() }
    
    // Coordination
    var close: Observable<Void> { _closeTapStream }
    var accountComplete: Observable<AccountModelType> { _accountCompleteStream }
    
    // Locals
    private let _closeTapStream = PublishSubject<Void>()
    private let _checkButtonStream = PublishSubject<Void>()
    private let _itemSelectedStream = PublishSubject<Int>()
    private let _accountCompleteStream = PublishSubject<AccountModelType>()
    
    private let _currentTitle: BehaviorRelay<String>
    private let _existingAccount = BehaviorRelay<AccountModelType?>(value: nil)
    private let _dataSource = BehaviorRelay<[BaseModalTableViewItem]>(value: [])
    
    init() {
        _currentTitle = BehaviorRelay<String>(value: "Add Account")
        // create childs
        
        // _checkButtonStream -> fill _completedAccount if everything is ok,
        // or show validation error if not
        
        _dataSource.accept([.titleInput(viewModel: TitleInputCellViewModel())])
    }
    
    func setupAccountToEdit(_ accountToEdit: AccountModelType) {
        _currentTitle.accept("Edit Account")
        _existingAccount.accept(accountToEdit)
        // fill childs with accountToEdit's values
    }
}
