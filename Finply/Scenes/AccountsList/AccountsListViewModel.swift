//
//  AccountsListViewModel.swift
//  Finply
//
//  Created by Illia Postoienko on 23.10.2020.
//

import RxSwift
import RxCocoa

protocol AccountsListViewModelType {
    var backButtonTap: PublishSubject<Void> { get }
}

final class AccountsListViewModel: AccountsListViewModelType {
        
    let backButtonTap: PublishSubject<Void> = PublishSubject<Void>()
}
