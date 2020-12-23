//  
//  AddEditAccountCoordinator.swift
//  Finply
//
//  Created by Illia Postoienko on 10.11.2020.
//

import UIKit
import RxSwift
import Dip

enum AddEditAccountCoordinationResult {
    case close
    case accountAdded(AccountModelType)
    case accountEdited(AccountModelType)
    case accountGroupAdded(AccountGroupModelType)
    case accountGroupEdited(AccountGroupModelType)
}

enum AddEditAccountSceneState {
    case addAccount
    case addAccountGroup
    case editAccount(AccountModelType)
    case editAccountGroup(AccountGroupModelType)
}

final class AddEditAccountCoordinator: BaseCoordinator<AddEditAccountCoordinationResult> {
    
    let state: AddEditAccountSceneState
    let presentingViewController: UIViewController
    let dependencyContainer: DependencyContainer
    
    private var viewController: AddEditAccountViewController!
    
    private let bag = DisposeBag()
    
    init(state: AddEditAccountSceneState, presentingViewController: UIViewController, dependencyContainer: DependencyContainer) {
        self.state = state
        self.presentingViewController = presentingViewController
        self.dependencyContainer = dependencyContainer
    }
    
    override func start() -> Observable<AddEditAccountCoordinationResult> {
        
        guard let viewModel = try? dependencyContainer.resolve() as AddEditAccountViewModelType else { return Observable.never() }
        
        viewModel.setup(with: state)
        
        var configuredResultStream: Observable<AddEditAccountCoordinationResult> {
            let streams = viewModel.coordination
            switch state {
            case .addAccount:       return streams.accountComplete.map{ .accountAdded($0) }
            case .editAccount:      return streams.accountComplete.map{ .accountEdited($0) }
            case .addAccountGroup:  return streams.accountGroupComplete.map{ .accountGroupAdded($0) }
            case .editAccountGroup: return streams.accountGroupComplete.map{ .accountGroupEdited($0) }
            }
        }
        
        viewController = AddEditAccountViewController.instantiate()
        viewController.bind(to: viewModel)
        
        viewModel.coordination.openCurrencyList
            .flatMap{ [unowned self] in self.coordinateToCurrencyList() }
            .subscribe(onNext: {
                switch $0 {
                case .selectedCurrency(let currency): return // pass to vm
                default: return
                }
            })
            .disposed(by: bag)
        
        viewModel.coordination.openColorSelection
            .flatMap{ [unowned self] in self.coordinateToColorSetsList() }
            .subscribe(onNext: {
                switch $0 {
                case .selectedColor: return // pass to vm
                case .selectedColorSet: return // pass to vm
                default: return
                }
            })
            .disposed(by: bag)
        
        viewModel.coordination.openIconSelection
            .flatMap{ [unowned self] in self.coordinateToIconsList() }
            .subscribe(onNext: {
                switch $0 {
                case .selectedIcon: return // pass to vm
                default: return
                }
            })
            .disposed(by: bag)
        
        presentingViewController.present(viewController, animated: true)
        
        return Observable.merge(
            [
                viewModel.coordination.close.map{ .close },
                configuredResultStream
            ])
            .take(1)
            .do(onNext: { [weak self] _ in self?.viewController.dismiss(animated: true) })
    }
    
    private func coordinateToCurrencyList() -> Observable<CurrencyListCoordinationResult> {
        let coordinator = CurrencyListCoordinator(presentingViewController: viewController,
                                                  dependencyContainer: dependencyContainer)
        return coordinate(to: coordinator)
    }
    
    private func coordinateToIconsList() -> Observable<IconsListCoordinationResult> {
        let coordinator = IconsListCoordinator(presentingViewController: viewController,
                                                  dependencyContainer: dependencyContainer)
        return coordinate(to: coordinator)
    }
    
    private func coordinateToColorSetsList() -> Observable<ColorSetsListCoordinationResult> {
        let coordinator = ColorSetsListCoordinator(presentingViewController: viewController,
                                                  dependencyContainer: dependencyContainer)
        return coordinate(to: coordinator)
    }
}

extension AddEditAccountSceneState {
    var editAccountValue: AccountModelType? {
        if case .editAccount(let accountModel) = self {
            return accountModel
        }
        return nil
    }
    
    var editAccountsGroupValue: AccountGroupModelType? {
        if case .editAccountGroup(let accountGroupModel) = self {
            return accountGroupModel
        }
        return nil
    }
}
