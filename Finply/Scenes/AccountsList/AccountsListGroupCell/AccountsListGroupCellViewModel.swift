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
    var accountGroupUpdate: AnyObserver<AccountGroupDto> { get }
    var editTap: AnyObserver<Void> { get }
    var deleteTap: AnyObserver<Void> { get }
    
    //Output
    var accountGroupModel: Observable<AccountGroupDto> { get }
    var editAccountGroup: Observable<AccountGroupDto> { get }
    var deleteAccountGroup: Observable<AccountGroupDto> { get }
    
    func getAccountGroupId() -> String
}

final class AccountsListGroupCellViewModel: AccountsListGroupCellViewModelType {
    
    // Input
    var accountGroupUpdate: AnyObserver<AccountGroupDto> { _accountGroupUpdate.asObserver() }
    var editTap: AnyObserver<Void> { _editTap.asObserver() }
    var deleteTap: AnyObserver<Void> { _deleteTap.asObserver() }
    
    private let _editTap = PublishSubject<Void>()
    private let _deleteTap = PublishSubject<Void>()
    private var _accountGroupUpdate = PublishSubject<AccountGroupDto>()
    
    // Output
    var accountGroupModel: Observable<AccountGroupDto> { _accountGroupModel.asObservable() }
    var editAccountGroup: Observable<AccountGroupDto> { _editAccountGroup }
    var deleteAccountGroup: Observable<AccountGroupDto> { _deleteAccountGroup }
    
    private let _editAccountGroup = PublishSubject<AccountGroupDto>()
    private let _deleteAccountGroup = PublishSubject<AccountGroupDto>()
    
    // Locals
    private let _accountGroupModel: BehaviorRelay<AccountGroupDto>
    private let bag = DisposeBag()
    
    init(accountGroupModel: AccountGroupDto) {
        _accountGroupModel = BehaviorRelay<AccountGroupDto>(value: accountGroupModel)
        
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
