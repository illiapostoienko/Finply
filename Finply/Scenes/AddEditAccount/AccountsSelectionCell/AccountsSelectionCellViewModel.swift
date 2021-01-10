//
//  AccountsSelectionCellViewModel.swift
//  Finply
//
//  Created by Illia Postoienko on 21.12.2020.
//

import RxSwift
import RxCocoa

protocol AccountsSelectionCellViewModelType {
    var allAccountItems: Observable<[AccountSelectionContainerViewModel]> { get }
    var selectedAccounts: Observable<[AccountDto]> { get }
    
    func setupLoadedAccounts(_ loadedAccounts: [AccountDto])
    func setupSelectedAccounts(_ selectedAccounts: [AccountDto])
}

final class AccountsSelectionCellViewModel: AccountsSelectionCellViewModelType {
    
    var allAccountItems: Observable<[AccountSelectionContainerViewModel]> { currentItems.asObservable() }
    var selectedAccounts: Observable<[AccountDto]> { selectedItems.asObservable() }
    
    private let currentItems = BehaviorRelay<[AccountSelectionContainerViewModel]>(value: [])
    private let selectedItems = BehaviorRelay<[AccountDto]>(value: [])
    
    private var loadedAccounts: [AccountDto] = []
    private var passedSelectedAccounts: [AccountDto] = []
    private let bag = DisposeBag()
    
    func setupLoadedAccounts(_ loadedAccounts: [AccountDto]) {
        self.loadedAccounts = loadedAccounts
        setup(with: loadedAccounts, selectedAccounts: passedSelectedAccounts)
    }
    
    func setupSelectedAccounts(_ selectedAccounts: [AccountDto]) {
        passedSelectedAccounts = selectedAccounts
        setup(with: loadedAccounts, selectedAccounts: passedSelectedAccounts)
    }
    
    private func setup(with accounts: [AccountDto], selectedAccounts: [AccountDto]) {
        var items: [AccountSelectionContainerViewModel] = []
        var streamsWithModels: [Observable<(isSelected: Bool, account: AccountDto)>] = []
        
        accounts.enumerated().forEach{ index, account in
            let shouldSelectFirst = selectedAccounts.isEmpty
            
            let isWithinSelectedOnes = selectedAccounts.map{ $0.id }.contains(account.id)
            
            let item = AccountSelectionContainerViewModel(isSelected: shouldSelectFirst ? index == 0 : isWithinSelectedOnes, account: account)
            
            let streamWithModel = item.isSelected.map{ (isSelected: $0, account: item.account) }
            
            items.append(item)
            streamsWithModels.append(streamWithModel)
        }

        Observable.combineLatest(streamsWithModels)
            .map{ streams -> [AccountDto] in
                var selectedAccounts: [AccountDto] = []
                streams.forEach { isSelected, account in if isSelected { selectedAccounts.append(account) }}
                return selectedAccounts
            }
            .bind(to: selectedItems)
            .disposed(by: bag)
        
        currentItems.accept(items)
    }
}
