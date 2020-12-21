//
//  AccountsListGroupCellViewModelType.swift
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
}

final class AccountsListGroupCellViewModel: AccountsListGroupCellViewModelType {
    
    let accountGroupModel: AccountGroupModelType
    
    var editTap: AnyObserver<Void> { _editTapStream.asObserver() }
    var deleteTap: AnyObserver<Void> { _deleteTapStream.asObserver() }
    
    private let _editTapStream = PublishSubject<Void>()
    private let _deleteTapStream = PublishSubject<Void>()
    private let bag = DisposeBag()
    
    init(accountGroupModel: AccountGroupModelType) {
        self.accountGroupModel = accountGroupModel
        
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
