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
}

protocol AddEditAccountViewModelOutput {
    var sceneState: AddEditAccountSceneState! { get }
    
    var dataSource: Observable<[AddEditAccountTableViewItem]> { get }
}

protocol AddEditAccountViewModelCoordination {
    var close: Observable<Void> { get }
    
    var accountComplete: Observable<AccountModelType> { get }
    var accountGroupComplete: Observable<AccountGroupModelType> { get }
    
    var openCurrencyList: Observable<Void> { get }
    var openColorSelection: Observable<Void> { get }
    var openIconSelection: Observable<Void> { get }
}

protocol AddEditAccountViewModelType {
    var output: AddEditAccountViewModelOutput { get }
    var input: AddEditAccountViewModelInput { get }
    var coordination: AddEditAccountViewModelCoordination { get }
    
    func setup(with state: AddEditAccountSceneState)
}

final class AddEditAccountViewModel: AddEditAccountViewModelType, AddEditAccountViewModelCoordination, AddEditAccountViewModelInput, AddEditAccountViewModelOutput {
    
    var input: AddEditAccountViewModelInput { return self }
    var output: AddEditAccountViewModelOutput { return self }
    var coordination: AddEditAccountViewModelCoordination { return self }
    
    // Output
    var sceneState: AddEditAccountSceneState!
    var dataSource: Observable<[AddEditAccountTableViewItem]> { _dataSource.asObservable() }
    
    // Input
    var closeButtonTap: AnyObserver<Void> { _closeTapStream.asObserver() }
    var checkButtonTap: AnyObserver<Void> { _checkButtonStream.asObserver() }
    var rowSelected: AnyObserver<Int> { _rowSelectedStream.asObserver() }
    
    // Coordination
    var close: Observable<Void> { _closeTapStream }
    var accountComplete: Observable<AccountModelType> { _accountCompleteStream }
    var accountGroupComplete: Observable<AccountGroupModelType>  { _accountGroupCompleteStream }
    var openCurrencyList: Observable<Void> { _openCurrencyListStream }
    var openColorSelection: Observable<Void> { _openColorSelectionStream }
    var openIconSelection: Observable<Void> { _openIconSelectionStream }
    
    // Local Streams
    private let _closeTapStream = PublishSubject<Void>()
    private let _checkButtonStream = PublishSubject<Void>()
    private let _openCurrencyListStream = PublishSubject<Void>()
    private let _openColorSelectionStream = PublishSubject<Void>() // with already selected Color
    private let _openIconSelectionStream = PublishSubject<Void>()
    private let _accountCompleteStream = PublishSubject<AccountModelType>()
    private let _accountGroupCompleteStream = PublishSubject<AccountGroupModelType>()
    private let _dataSource = BehaviorRelay<[AddEditAccountTableViewItem]>(value: [])
    private let _rowSelectedStream = PublishSubject<Int>()
    
    //Childs
    private let titleInputViewModel: TitleInputCellViewModelType
    private let ballanceInputCellViewModel: BallanceInputCellViewModelType
    private let iconSelectionCellViewModel: IconSelectionCellViewModelType
    private let colorSelectionCellViewModel: ColorSelectionCellViewModelType
    private let accountsSelectionCellViewModelType: AccountsSelectionCellViewModelType
    
    private let bag = DisposeBag()
    
    init(titleInputViewModel: TitleInputCellViewModelType = TitleInputCellViewModel(),
         ballanceInputCellViewModel: BallanceInputCellViewModelType = BallanceInputCellViewModel(),
         iconSelectionCellViewModel: IconSelectionCellViewModelType = IconSelectionCellViewModel(),
         colorSelectionCellViewModel: ColorSelectionCellViewModelType = ColorSelectionCellViewModel(),
         accountsSelectionCellViewModelType: AccountsSelectionCellViewModelType = AccountsSelectionCellViewModel())
    {
        self.titleInputViewModel = titleInputViewModel
        self.ballanceInputCellViewModel = ballanceInputCellViewModel
        self.iconSelectionCellViewModel = iconSelectionCellViewModel
        self.colorSelectionCellViewModel = colorSelectionCellViewModel
        self.accountsSelectionCellViewModelType = accountsSelectionCellViewModelType
        
        ballanceInputCellViewModel.currencyTapped
            .bind(to: _openCurrencyListStream)
            .disposed(by: bag)
        
        let selectedItemStream = _rowSelectedStream
            .withLatestFrom(_dataSource) { row, dataSource in dataSource[safe: row] }
            .unwrap()
        
        //Color selection
        selectedItemStream
            .map{ item -> ColorSelectionCellViewModelType? in
                if case .colorSelect(let vm) = item { return vm }
                return nil
            }
            .unwrap()
            .map{ _ in } // get current color
            .bind(to: _openColorSelectionStream)
            .disposed(by: bag)
        
        //Icon Selection
        selectedItemStream
            .map{ item -> IconSelectionCellViewModelType? in
                if case .iconSelect(let vm) = item { return vm }
                return nil
            }
            .unwrap()
            .map{ _ in } // get current icon
            .bind(to: _openIconSelectionStream)
            .disposed(by: bag)
    }
    
    func setup(with state: AddEditAccountSceneState) {
        
        _dataSource.accept([
            .titleInput(viewModel: titleInputViewModel),
            .ballanceInput(viewModel: ballanceInputCellViewModel),
            .iconSelect(viewModel: iconSelectionCellViewModel),
            .colorSelect(viewModel: colorSelectionCellViewModel)
        ])
    }
}

enum AddEditAccountTableViewItem: IdentifiableType, Equatable {
    
    //add/edit Account or Group
    case titleInput(viewModel: TitleInputCellViewModelType)
    case ballanceInput(viewModel: BallanceInputCellViewModelType)
    case iconSelect(viewModel: IconSelectionCellViewModelType)
    case colorSelect(viewModel: ColorSelectionCellViewModelType)
    case accountsSelect(viewModel: AccountsSelectionCellViewModelType)
    
    var identity: String {
        switch self {
        case .titleInput: return "titleTextField"
        case .ballanceInput: return "ballanceInput"
        case .iconSelect: return "iconSelect"
        case .colorSelect: return "colorSelect"
        case .accountsSelect: return "accountsSelect"
        }
    }
    
    static func == (lhs: AddEditAccountTableViewItem, rhs: AddEditAccountTableViewItem) -> Bool {
        return lhs.identity == rhs.identity
    }
}
