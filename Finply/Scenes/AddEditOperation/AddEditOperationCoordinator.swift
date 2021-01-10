//
//  AddEditOperationCoordinator.swift
//  Finply
//
//  Created by Illia Postoienko on 30.09.2020.
//

import UIKit
import RxSwift
import Dip

enum AddEditOperationCoordinationResult {
    case operationAdded(OperationDto)
    case operationEdited(OperationDto)
    case close
}

final class AddEditOperationCoordinator: BaseCoordinator<AddEditOperationCoordinationResult> {
    
    let presentingViewController: UIViewController
    let dependencyContainer: DependencyContainer
    
    private let selfDismissStream = PublishSubject<Void>()
    
    init(presentingViewController: UIViewController, dependencyContainer: DependencyContainer, operationToEdit: OperationDto? = nil) {
        self.presentingViewController = presentingViewController
        self.dependencyContainer = dependencyContainer

    }
    
    override func start() -> Observable<AddEditOperationCoordinationResult> {
        
        guard let viewModel = try? dependencyContainer.resolve() as AddEditOperationViewModelType else { return Observable.never() }
        
        var vc = AddEditOperationViewController.instantiate()
        vc.bind(to: viewModel)
        
        presentingViewController.present(vc, animated: true)
        
        return Observable.never()
    }
}
