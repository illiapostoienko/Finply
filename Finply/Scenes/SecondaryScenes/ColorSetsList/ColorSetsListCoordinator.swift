//  
//  ColorSetsListCoordinator.swift
//  Finply
//
//  Created by Illia Postoienko on 23.12.2020.
//

import UIKit
import RxSwift
import Dip

enum ColorSetsListCoordinationResult {
    case close
    case selectedColor
    case selectedColorSet
}

final class ColorSetsListCoordinator: BaseCoordinator<ColorSetsListCoordinationResult> {
    
    let presentingViewController: UIViewController
    let dependencyContainer: DependencyContainer
    
    init(presentingViewController: UIViewController, dependencyContainer: DependencyContainer) {
        self.presentingViewController = presentingViewController
        self.dependencyContainer = dependencyContainer
    }
    
    override func start() -> Observable<ColorSetsListCoordinationResult> {
        
        guard let viewModel = try? dependencyContainer.resolve() as ColorSetsListViewModelType else { return Observable.never() }
        var vc = ColorSetsListViewController.instantiate()
        vc.bind(to: viewModel)
        
        presentingViewController.present(vc, animated: true)
        
        // TODO: All returnings from VM converted to coordination result
        
        return Observable.never()
    }
}
