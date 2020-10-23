//
//  HomeScreenViewModel.swift
//  Finply
//
//  Created by Illia Postoienko on 30.09.2020.
//

import RxSwift
import RxCocoa

protocol HomeScreenViewModelType {
    
    var addButtonPressed: PublishSubject<Void> { get }
    var editButtonPressed: PublishSubject<Void> { get }
    var accountsListPressed: PublishSubject<Void> { get }
}

final class HomeScreenViewModel: HomeScreenViewModelType {
    
    let addButtonPressed = PublishSubject<Void>()
    let editButtonPressed = PublishSubject<Void>()
    let accountsListPressed = PublishSubject<Void>()
    
    private let accountService: FPAccountServiceType
    
    init(accountService: FPAccountServiceType) {
        self.accountService = accountService
    }
}
