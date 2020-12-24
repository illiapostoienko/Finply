//
//  AccountsListGroupCellViewModel.swift
//  Finply
//
//  Created by Illia Postoienko on 27.11.2020.
//

import RxSwift
import RxCocoa

protocol AccountsListGroupCellViewModelType {
    
    //Input
    var accountGroupUpdate: AnyObserver<AccountGroupModelType> { get }
    var editTap: AnyObserver<Void> { get }
    var deleteTap: AnyObserver<Void> { get }
    
    //Output
    var accountGroupModel: Observable<AccountGroupModelType> { get }
    var editAccountGroup: Observable<AccountGroupModelType> { get }
    var deleteAccountGroup: Observable<AccountGroupModelType> { get }
    
    func getAccountGroupId() -> String
}

final class AccountsListGroupCellViewModel: AccountsListGroupCellViewModelType {
    
    // Input
    var accountGroupUpdate: AnyObserver<AccountGroupModelType> { _accountGroupUpdate.asObserver() }
    var editTap: AnyObserver<Void> { _editTap.asObserver() }
    var deleteTap: AnyObserver<Void> { _deleteTap.asObserver() }
    
    private let _editTap = PublishSubject<Void>()
    private let _deleteTap = PublishSubject<Void>()
    private var _accountGroupUpdate = PublishSubject<AccountGroupModelType>()
    
    // Output
    var accountGroupModel: Observable<AccountGroupModelType> { _accountGroupModel.asObservable() }
    var editAccountGroup: Observable<AccountGroupModelType> { _editAccountGroup }
    var deleteAccountGroup: Observable<AccountGroupModelType> { _deleteAccountGroup }
    
    private let _editAccountGroup = PublishSubject<AccountGroupModelType>()
    private let _deleteAccountGroup = PublishSubject<AccountGroupModelType>()
    
    // Locals
    private let _accountGroupModel: BehaviorRelay<AccountGroupModelType>
    private let bag = DisposeBag()
    
    init(accountGroupModel: AccountGroupModelType) {        
        _accountGroupModel = BehaviorRelay<AccountGroupModelType>(value: accountGroupModel)
        
        _accountGroupUpdate
            .bind(to: _accountGroupModel)
            .disposed(by: bag)
        
        _editTap
            .withLatestFrom(_accountGroupModel)
            .bind(to: _editAccountGroup)
            .disposed(by: bag)
        
        _deleteTap
            .withLatestFrom(_accountGroupModel)
            .bind(to: _deleteAccountGroup)
            .disposed(by: bag)
    }
    
    func getAccountGroupId() -> String {
        _accountGroupModel.value.id
    }
}
