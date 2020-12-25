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
    var accountModel: Observable<AccountDto> { get }
    
    //Input
    var editTap: AnyObserver<Void> { get }
    var deleteTap: AnyObserver<Void> { get }
    
    //Output
    var editAccount: Observable<AccountDto> { get }
    var deleteAccount: Observable<AccountDto> { get }
    
    func getAccountId() -> String
}

final class AccountsListAccountCellViewModel: AccountsListAccountCellViewModelType {
    
    var accountModel: Observable<AccountDto> { _accountModel.asObservable() }
    
    // Input
    var editTap: AnyObserver<Void> { _editTap.asObserver() }
    var deleteTap: AnyObserver<Void> { _deleteTap.asObserver() }
    
    private let _editTap = PublishSubject<Void>()
    private let _deleteTap = PublishSubject<Void>()
    
    // Output
    var editAccount: Observable<AccountDto> { _editAccount }
    var deleteAccount: Observable<AccountDto> { _deleteAccount }
    
    private let _editAccount = PublishSubject<AccountDto>()
    private let _deleteAccount = PublishSubject<AccountDto>()
    
    // Locals
    private let _accountModel: BehaviorRelay<AccountDto>
    private let bag = DisposeBag()
    
    init(accountModel: AccountDto) {
        _accountModel = BehaviorRelay<AccountDto>(value: accountModel)
        
        _editTap
            .withLatestFrom(_accountModel)
            .bind(to: _editAccount)
            .disposed(by: bag)
        
        _deleteTap
            .withLatestFrom(_accountModel)
            .bind(to: _deleteAccount)
            .disposed(by: bag)
    }
    
    func getAccountId() -> String {
        _accountModel.value.id
    }
}
