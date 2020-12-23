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
    case operationAdded(FPOperation)
    case operationEdited(FPOperation)
    case close
}

final class AddEditOperationCoordinator: BaseCoordinator<AddEditOperationCoordinationResult> {
    
    let presentingViewController: UIViewController
    let dependencyContainer: DependencyContainer
    let operationToEdit: FPOperation?
    
    private let selfDismissStream = PublishSubject<Void>()
    
    init(presentingViewController: UIViewController, dependencyContainer: DependencyContainer, operationToEdit: FPOperation? = nil) {
        self.presentingViewController = presentingViewController
        self.dependencyContainer = dependencyContainer
        self.operationToEdit = operationToEdit
    }
    
    override func start() -> Observable<AddEditOperationCoordinationResult> {
        
        guard let viewModel = try? dependencyContainer.resolve() as AddEditOperationViewModelType else { return Observable.never() }
        
        var vc = AddEditOperationViewController.instantiate()
        vc.bind(to: viewModel)
        
        presentingViewController.present(vc, animated: true)
        
        return Observable.merge(
            [
                viewModel.cancelTapped.map{ .close },
                viewModel.operationAdded.map{ .operationAdded($0) },
                viewModel.operationEdited.map{ .operationEdited($0) }
            ])
            .take(1)
            .do(onNext: { [vc] _ in vc.dismiss(animated: true) })
    }
}
