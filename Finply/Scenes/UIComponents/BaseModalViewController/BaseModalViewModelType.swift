//
//  BaseModalViewModelType.swift
//  Finply
//
//  Created by Illia Postoienko on 28.11.2020.
//

import RxSwift
import RxCocoa
import RxDataSources

protocol BaseModalViewModelInput {
    var closeButtonTap: AnyObserver<Void> { get }
    var checkButtonTap: AnyObserver<Void> { get }
    var itemSelected: AnyObserver<Int> { get }
}

protocol BaseModalViewModelOutput {
    var dataSource: Observable<[BaseModalTableViewItem]> { get }
    var title: String { get }
    var isCheckButtonHidden: Bool { get }
}

protocol BaseModalViewModelType {
    var input: BaseModalViewModelInput { get }
    var output: BaseModalViewModelOutput { get }
}

enum BaseModalTableViewItem: IdentifiableType, Equatable {
    
    //add/edit Account or Group
    case titleInput(viewModel: TitleInputCellViewModelType)
    case ballanceInput
    case currencySelect
    case iconSelect
    case colorSelect
    case accountsSelect
    
    // add/edit Operation
    
    
    var identity: String {
        switch self {
        case .titleInput: return "titleTextField"
        case .ballanceInput: return "ballanceInput"
        case .currencySelect: return "currencySelect"
        case .iconSelect: return "iconSelect"
        case .colorSelect: return "colorSelect"
        case .accountsSelect: return "accountsSelect"
        }
    }
    
    static func == (lhs: BaseModalTableViewItem, rhs: BaseModalTableViewItem) -> Bool {
        return lhs.identity == rhs.identity
    }
}
