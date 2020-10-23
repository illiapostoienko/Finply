//  ___FILEHEADER___

import UIKit
import RxSwift
import Dip

enum ___VARIABLE_productName___CoordinationResult {

}

final class ___FILEBASENAMEASIDENTIFIER___: BaseCoordinator<___VARIABLE_productName___CoordinationResult> {
    
    let presentingViewController: UIViewController
    let dependencyContainer: DependencyContainer
    
    init(presentingViewController: UIViewController, dependencyContainer: DependencyContainer) {
        self.presentingViewController = presentingViewController
        self.dependencyContainer = dependencyContainer
    }
    
    override func start() -> Observable<___VARIABLE_productName___CoordinationResult> {
        
        guard let viewModel = try? dependencyContainer.resolve() as ___VARIABLE_productName___ViewModelType else { return Observable.never() }
        var vc = ___VARIABLE_productName___ViewController.instantiate()
        vc.bind(to: viewModel)
        
        presentingViewController.present(vc, animated: true)
        
        // TODO: All returnings from VM converted to coordination result
        
        return Observable.never()
    }
}
