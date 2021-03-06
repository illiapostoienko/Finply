//  
//  AddEditAccountViewModel.swift
//  Finply
//
//  Created by Illia Postoienko on 10.11.2020.
//

import RxSwift
import RxCocoa
import RxDataSources

protocol AddEditAccountViewModelInput {
    var closeButtonTap: AnyObserver<Void> { get }
    var checkButtonTap: AnyObserver<Void> { get }
    var rowSelected: AnyObserver<Int> { get }
    
    var currencyListResult: AnyObserver<CurrencyListCoordinationResult> { get }
    var iconsListResult: AnyObserver<IconsListCoordinationResult> { get }
    var colorSetsListResult: AnyObserver<ColorSetsListCoordinationResult> { get }
}

protocol AddEditAccountViewModelOutput {
    var sceneState: Observable<AddEditAccountSceneState> { get }
    var dataSource: Observable<[AddEditAccountTableViewItem]> { get }
    var isCheckButtonEnabled: Observable<Bool> { get }
}

protocol AddEditAccountViewModelCoordination {
    var completeCoordinationResult: Observable<AddEditAccountCoordinationResult> { get }
    
    var openCurrencyList: Observable<Currency> { get }
    var openColorSelection: Observable<Void> { get }
    var openIconSelection: Observable<Void> { get }
}

protocol AddEditAccountViewModelType {
    var output: AddEditAccountViewModelOutput { get }
    var input: AddEditAccountViewModelInput { get }
    var coordination: AddEditAccountViewModelCoordination { get }
    
    func setup(with state: AddEditAccountSceneState)
}

// swiftlint:disable force_unwrapping
final class AddEditAccountViewModel: AddEditAccountViewModelType, AddEditAccountViewModelCoordination, AddEditAccountViewModelInput, AddEditAccountViewModelOutput {
    
    var input: AddEditAccountViewModelInput { return self }
    var output: AddEditAccountViewModelOutput { return self }
    var coordination: AddEditAccountViewModelCoordination { return self }
    
    // Output
    var sceneState: Observable<AddEditAccountSceneState> { _sceneState.asObservable() }
    var dataSource: Observable<[AddEditAccountTableViewItem]> { _dataSource.asObservable() }
    let isCheckButtonEnabled: Observable<Bool>
    
    private let _sceneState = BehaviorRelay<AddEditAccountSceneState>(value: .addAccount)
    private let _dataSource = BehaviorRelay<[AddEditAccountTableViewItem]>(value: [])
    
    // Input
    var closeButtonTap: AnyObserver<Void> { _closeButtonTap.asObserver() }
    var checkButtonTap: AnyObserver<Void> { _checkButtonTap.asObserver() }
    var rowSelected: AnyObserver<Int> { _rowSelected.asObserver() }
    
    var currencyListResult: AnyObserver<CurrencyListCoordinationResult> { _currencyListResult.asObserver() }
    var iconsListResult: AnyObserver<IconsListCoordinationResult> { _iconsListResult.asObserver() }
    var colorSetsListResult: AnyObserver<ColorSetsListCoordinationResult> { _colorSetsListResult.asObserver() }
    
    private let _closeButtonTap = PublishSubject<Void>()
    private let _checkButtonTap = PublishSubject<Void>()
    private let _rowSelected = PublishSubject<Int>()
    private let _currencyListResult = PublishSubject<CurrencyListCoordinationResult>()
    private let _iconsListResult = PublishSubject<IconsListCoordinationResult>()
    private let _colorSetsListResult = PublishSubject<ColorSetsListCoordinationResult>()
    
    // Coordination
    var completeCoordinationResult: Observable<AddEditAccountCoordinationResult> { _completeCoordinationResult }
    var openCurrencyList: Observable<Currency> { _openCurrencyList }
    var openColorSelection: Observable<Void> { _openColorSelection }
    var openIconSelection: Observable<Void> { _openIconSelection }
    
    private let _completeCoordinationResult = PublishSubject<AddEditAccountCoordinationResult>()
    private let _openCurrencyList = PublishSubject<Currency>()
    private let _openColorSelection = PublishSubject<Void>() // with already selected Color?
    private let _openIconSelection = PublishSubject<Void>() // with already selected icon?
    
    // Childs
    private let titleInputVm: TitleInputCellViewModelType
    private let ballanceInputCellVm: BallanceInputCellViewModelType
    private let iconSelectionCellVm: IconSelectionCellViewModelType
    private let colorSelectionCellVm: ColorSelectionCellViewModelType
    private let accountsSelectionCellVm: AccountsSelectionCellViewModelType
    
    private let accountsService: AccountsServiceType
    private let accountsRepository: AccountsRepositoryType
    private let bag = DisposeBag()
    
    init(accountsService: AccountsServiceType,
         accountsRepository: AccountsRepositoryType,
         titleInputVm: TitleInputCellViewModelType = TitleInputCellViewModel(),
         ballanceInputCellVm: BallanceInputCellViewModelType = BallanceInputCellViewModel(),
         iconSelectionCellVm: IconSelectionCellViewModelType = IconSelectionCellViewModel(),
         colorSelectionCellVm: ColorSelectionCellViewModelType = ColorSelectionCellViewModel(),
         accountsSelectionCellVm: AccountsSelectionCellViewModelType = AccountsSelectionCellViewModel())
    {
        self.accountsService = accountsService
        self.accountsRepository = accountsRepository
        self.titleInputVm = titleInputVm
        self.ballanceInputCellVm = ballanceInputCellVm
        self.iconSelectionCellVm = iconSelectionCellVm
        self.colorSelectionCellVm = colorSelectionCellVm
        self.accountsSelectionCellVm = accountsSelectionCellVm
        
        ballanceInputCellVm.currencyTapped
            .withLatestFrom(ballanceInputCellVm.selectedCurrency)
            .bind(to: _openCurrencyList)
            .disposed(by: bag)
        
        let selectedItemStream = _rowSelected
            .withLatestFrom(_dataSource) { row, dataSource in dataSource[safe: row] }
            .unwrap()
        
        // Color selection
        selectedItemStream
            .map{ item -> ColorSelectionCellViewModelType? in
                if case .colorSelect(let vm) = item { return vm }
                return nil
            }
            .unwrap()
            .map{ _ in } // get current color set
            .bind(to: _openColorSelection)
            .disposed(by: bag)
        
        // Icon Selection
        selectedItemStream
            .map{ item -> IconSelectionCellViewModelType? in
                if case .iconSelect(let vm) = item { return vm }
                return nil
            }
            .unwrap()
            .map{ _ in } // get current icon
            .bind(to: _openIconSelection)
            .disposed(by: bag)
        
        _currencyListResult
            .bind(to: ballanceInputCellVm.currencyListResult)
            .disposed(by: bag)
        
        _iconsListResult
            .bind(to: iconSelectionCellVm.iconsListResult)
            .disposed(by: bag)
        
        _colorSetsListResult.bind(to: colorSelectionCellVm.colorSetsListResult)
            .disposed(by: bag)
        
        _closeButtonTap
            .map{ .close }
            .bind(to: _completeCoordinationResult)
            .disposed(by: bag)
        
        let latestAccountDataSet = Observable
            .combineLatest(titleInputVm.currentName, ballanceInputCellVm.ballanceInCents, ballanceInputCellVm.selectedCurrency)
            .map{ (name: $0.0, value: $0.1, currency: $0.2) }

        let latestAccountGroupDataSet = Observable
            .combineLatest(titleInputVm.currentName, accountsSelectionCellVm.selectedAccounts)
            .map{ (name: $0.0, selectedAccounts: $0.1) }
        
        isCheckButtonEnabled = _sceneState.flatMap { state -> Observable<Bool> in
            if state.isAccountGroupAction {
                return latestAccountGroupDataSet.map{ set in !set.name.isEmpty && !set.selectedAccounts.isEmpty }
            } else {
                return latestAccountDataSet.map{ set in
                    guard let inputValueInCents = set.value else { return false }
                    return !set.name.isEmpty && inputValueInCents != 0
                }
            }
        }
        
        // Adding/Updaing Account
        _checkButtonTap
            .withLatestFrom(_sceneState)
            .filter{ $0.isAccountAction }
            .withLatestFrom(latestAccountDataSet) { (state: $0, data: $1) }
            .filter{ $0.data.value != nil }
            .flatMap{ [accountsService] set -> Single<AddEditAccountCoordinationResult> in
                if var existingAccount = set.state.editAccountValue {
                    let calculatedValueDelta = existingAccount.calculatedValueInCents - existingAccount.baseValueInCents
                    
                    existingAccount.name = set.data.name
                    existingAccount.baseValueInCents = set.data.value!
                    existingAccount.calculatedValueInCents = set.data.value! + calculatedValueDelta
                    existingAccount.currency = set.data.currency
                    // + icon, color
                    
                    return accountsService
                        .updateAccount(existingAccount)
                        .map{ .accountEdited(existingAccount) }
                } else {
                    return accountsService
                        .addAccount(name: set.data.name, baseValueInCents: set.data.value!, calculatedValueInCents: set.data.value!, currency: set.data.currency)
                        .map{ .accountAdded($0) }
                }
            }
            .bind(to: _completeCoordinationResult)
            .disposed(by: bag)
        
        // Adding/Updaing AccountGroup
        _checkButtonTap
            .withLatestFrom(_sceneState)
            .filter{ $0.isAccountGroupAction }
            .withLatestFrom(latestAccountGroupDataSet) { (state: $0, data: $1) }
            .flatMap{ [accountsService] set -> Single<AddEditAccountCoordinationResult> in
                if var existingAccountGroup = set.state.editAccountGroupValue {
                    
                    existingAccountGroup.name = set.data.name
                    existingAccountGroup.accounts = set.data.selectedAccounts
                    // + icon, color, selected accounts
                    
                    return accountsService
                        .updateAccountGroup(existingAccountGroup)
                        .map{ .accountGroupEdited(existingAccountGroup) }
                } else {
                    return accountsService
                        .addAccountGroup(name: set.data.name, accounts: set.data.selectedAccounts)
                        .map{ .accountGroupAdded($0) }
                }
            }
            .bind(to: _completeCoordinationResult)
            .disposed(by: bag)
        
        _sceneState
            .map{ state -> [AddEditAccountTableViewItem] in
                var itemsSet: [AddEditAccountTableViewItem] = []
                
                state.existingName.map{ titleInputVm.setCurrentName($0) }
                itemsSet.append(.titleInput(viewModel: titleInputVm))
                
                if state.isAccountAction {
                    state.existingBallance.map{ ballanceInputCellVm.setCurrentBallance($0) }
                    state.existingCurrency.map{ ballanceInputCellVm.setCurrentCurrency($0)}
                    itemsSet.append(.ballanceInput(viewModel: ballanceInputCellVm))
                }
            
                itemsSet.append(.clear)
                
                itemsSet.append(.iconSelect(viewModel: iconSelectionCellVm))
                itemsSet.append(.colorSelect(viewModel: colorSelectionCellVm))
                
                if state.isAccountGroupAction {
                    accountsSelectionCellVm.setupSelectedAccounts(state.existingSelectedAccounts ?? [])
                    itemsSet.append(.accountsSelect(viewModel: accountsSelectionCellVm))
                }
                
                return itemsSet
            }
            .bind(to: _dataSource)
            .disposed(by: bag)
        
        accountsRepository.getAccountsOrdered()
            .subscribe(onSuccess: { [weak self] accounts in
                self?.accountsSelectionCellVm.setupLoadedAccounts(accounts)
            })
            .disposed(by: bag)
    }
    
    func setup(with state: AddEditAccountSceneState) {
        guard _sceneState.value != state else { return }
        _sceneState.accept(state)
    }
}

enum AddEditAccountTableViewItem: IdentifiableType, Equatable {
    
    case titleInput(viewModel: TitleInputCellViewModelType)
    case ballanceInput(viewModel: BallanceInputCellViewModelType)
    case iconSelect(viewModel: IconSelectionCellViewModelType)
    case colorSelect(viewModel: ColorSelectionCellViewModelType)
    case accountsSelect(viewModel: AccountsSelectionCellViewModelType)
    case clear
    
    var identity: String {
        switch self {
        case .titleInput: return "titleTextField"
        case .ballanceInput: return "ballanceInput"
        case .iconSelect: return "iconSelect"
        case .colorSelect: return "colorSelect"
        case .accountsSelect: return "accountsSelect"
        case .clear: return "clear"
        }
    }
    
    static func == (lhs: AddEditAccountTableViewItem, rhs: AddEditAccountTableViewItem) -> Bool {
        return lhs.identity == rhs.identity
    }
}

extension AddEditAccountSceneState: Equatable {
    
    static func == (lhs: AddEditAccountSceneState, rhs: AddEditAccountSceneState) -> Bool {
        switch (lhs, rhs) {
        case (.addAccount, .addAccount): return true
        case (.addAccountGroup, .addAccountGroup): return true
        case (.editAccount(let left), .editAccount(let right)): return left.id == right.id
        case (.editAccountGroup(let left), .editAccountGroup(let right)): return left.id == right.id
        default: return false
        }
    }
    
    var editAccountValue: AccountDto? {
        if case .editAccount(let accountModel) = self {
            return accountModel
        }
        return nil
    }
    
    var editAccountGroupValue: AccountGroupDto? {
        if case .editAccountGroup(let accountGroupModel) = self {
            return accountGroupModel
        }
        return nil
    }
    
    var isAccountAction: Bool {
        if case .editAccount = self { return true }
        else if case .addAccount = self { return true }
        return false
    }
    
    var isAccountGroupAction: Bool {
        if case .editAccountGroup = self { return true }
        else if case .addAccountGroup = self { return true }
        return false
    }
    
    var isAddAction: Bool {
        if case .addAccount = self { return true }
        else if case .addAccountGroup = self { return true }
        return false
    }
    
    var existingName: String? {
        if case .editAccount(let existingAccount) = self { return existingAccount.name }
        if case .editAccountGroup(let existingAccountGroup) = self { return existingAccountGroup.name }
        return nil
    }
    
    var existingBallance: Int? {
        if case .editAccount(let existingAccount) = self { return existingAccount.baseValueInCents }
        return nil
    }
    
    var existingCurrency: Currency? {
        if case .editAccount(let existingAccount) = self { return existingAccount.currency }
        return nil
    }
    
    var existingSelectedAccounts: [AccountDto]? {
        if case .editAccountGroup(let existingAccountGroup) = self { return existingAccountGroup.accounts }
        return nil
    }
    
    // icon, color
    
    var title: String {
        switch self {
        case .addAccount: return "Add Account"
        case .addAccountGroup: return "Add Accounts Group"
        case .editAccount: return "Edit Account"
        case .editAccountGroup:  return "Edit Accounts Group"
        }
    }
}
