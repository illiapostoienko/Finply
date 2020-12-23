//
//  AccountsListGroupCellViewModel.swift
//  Finply
//
//  Created by Illia Postoienko on 27.11.2020.
//

import RxSwift
import RxCocoa

protocol AccountsListGroupCellViewModelType {
    var accountGroupModel: AccountGroupModelType { get }
    
    //Input
    var editTap: AnyObserver<Void> { get }
    var deleteTap: AnyObserver<Void> { get }
    
    //Output
    var editAccountGroup: Observable<AccountGroupModelType> { get }
    var deleteAccountGroup: Observable<AccountGroupModelType> { get }
}

final class AccountsListGroupCellViewModel: AccountsListGroupCellViewModelType {
    
    let accountGroupModel: AccountGroupModelType
    
    // Input
    var editTap: AnyObserver<Void> { _editTap.asObserver() }
    var deleteTap: AnyObserver<Void> { _deleteTap.asObserver() }
    
    private let _editTap = PublishSubject<Void>()
    private let _deleteTap = PublishSubject<Void>()
    
    // Output
    var editAccountGroup: Observable<AccountGroupModelType> { _editAccountGroup }
    var deleteAccountGroup: Observable<AccountGroupModelType> { _deleteAccountGroup }
    
    private let _editAccountGroup = PublishSubject<AccountGroupModelType>()
    private let _deleteAccountGroup = PublishSubject<AccountGroupModelType>()
    
    // Locals
    private let _accountGroupModel: BehaviorRelay<AccountGroupModelType>
    private let bag = DisposeBag()
    
    init(accountGroupModel: AccountGroupModelType) {
        self.accountGroupModel = accountGroupModel
        
        _accountGroupModel = BehaviorRelay<AccountGroupModelType>(value: accountGroupModel)
        
        _editTap
            .withLatestFrom(_accountGroupModel)
            .bind(to: _editAccountGroup)
            .disposed(by: bag)
        
        _deleteTap
            .withLatestFrom(_accountGroupModel)
            .bind(to: _deleteAccountGroup)
            .disposed(by: bag)
    }
}
