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
}

final class AccountsListAccountCellViewModel: AccountsListAccountCellViewModelType {
    
    let accountModel: AccountModelType
    
    var editTap: AnyObserver<Void> { _editTapStream.asObserver() }
    var deleteTap: AnyObserver<Void> { _deleteTapStream.asObserver() }
    
    private let _editTapStream = PublishSubject<Void>()
    private let _deleteTapStream = PublishSubject<Void>()
    private let bag = DisposeBag()
    
    init(accountModel: AccountModelType = AccountModel(name: "Some name", baseValueInCents: 0, currency: .afghani, order: 0)) {
        self.accountModel = accountModel
        
        _editTapStream
            .subscribe(onNext: {
                print("edit taped")
            })
            .disposed(by: bag)
        
        _deleteTapStream
            .subscribe(onNext: {
                print("delete taped")
            })
            .disposed(by: bag)
    }
}
