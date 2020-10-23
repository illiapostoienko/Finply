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
    case addedOperation(FPOperation)
    case editedOperation(FPOperation)
    case cancel
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
        
        vc.presentationController?.delegate = self
        
        let selfDismiss = selfDismissStream.map{ AddEditOperationCoordinationResult.cancel }
        
        let cancel = viewModel.cancelTapped.map{ AddEditOperationCoordinationResult.cancel }
        let operationAdded = viewModel.operationAdded.map{ AddEditOperationCoordinationResult.addedOperation($0) }
        let operationEdited = viewModel.operationEdited.map{ AddEditOperationCoordinationResult.editedOperation($0) }
        
        let viewModelReturnStream = Observable.merge(cancel, operationAdded, operationEdited)
            .take(1)
            .do(onNext: { [vc] _ in vc.dismiss(animated: true) })
        
        return Observable.merge(viewModelReturnStream, selfDismiss).take(1)
    }
}

extension AddEditOperationCoordinator: UIAdaptivePresentationControllerDelegate {
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        selfDismissStream.onNext(())
    }
}
