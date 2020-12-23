//
//  AccountsListAccountCellViewModel.swift
//  Finply
//
//  Created by Illia Postoienko on 27.11.2020.
//

import RxSwift
import RxCocoa
import Foundation

protocol AccountsListAccountCellViewModelType {
    var accountModel: AccountModelType { get }
    
    //Input
    var editTap: AnyObserver<Void> { get }
    var deleteTap: AnyObserver<Void> { get }
    
    //Output
    var editAccount: Observable<AccountModelType> { get }
    var deleteAccount: Observable<AccountModelType> { get }
}

final class AccountsListAccountCellViewModel: AccountsListAccountCellViewModelType {
    
    var accountModel: AccountModelType { _accountModel.value }
    
    // Input
    var editTap: AnyObserver<Void> { _editTap.asObserver() }
    var deleteTap: AnyObserver<Void> { _deleteTap.asObserver() }
    
    private let _editTap = PublishSubject<Void>()
    private let _deleteTap = PublishSubject<Void>()
    
    // Output
    var editAccount: Observable<AccountModelType> { _editAccount }
    var deleteAccount: Observable<AccountModelType> { _deleteAccount }
    
    private let _editAccount = PublishSubject<AccountModelType>()
    private let _deleteAccount = PublishSubject<AccountModelType>()
    
    // Locals
    private let _accountModel: BehaviorRelay<AccountModelType>
    private let bag = DisposeBag()
    
    init(accountModel: AccountModelType = AccountModel(name: "Some name", baseValueInCents: 0, currency: .afghani, order: 0)) {

        _accountModel = BehaviorRelay<AccountModelType>(value: accountModel)
        
        _editTap
            .withLatestFrom(_accountModel)
            .bind(to: _editAccount)
            .disposed(by: bag)
        
        _deleteTap
            .withLatestFrom(_accountModel)
            .bind(to: _deleteAccount)
            .disposed(by: bag)
    }
}
