//
//  AppCoordinator.swift
//  Finply
//
//  Created by Illia Postoienko on 30.09.2020.
//

import UIKit
import Dip
import RxSwift

class AppCoordinator: BaseCoordinator<Void> {

    let window: UIWindow
    let dependencyContainer: DependencyContainer
    let bag = DisposeBag()
    
    init(window: UIWindow, dependencyContainer: DependencyContainer) {
        self.window = window
        self.dependencyContainer = dependencyContainer
        
        super.init()
    }

    override func start() -> Observable<Void> {
        
        //TODO: setup side menus container in future
        
        let homeScreenCoordinator = HomeScreenCoordinator(dependencyContainer: dependencyContainer)

        window.rootViewController = homeScreenCoordinator.instantiatedViewController()
        window.makeKeyAndVisible()

        return self.coordinate(to: homeScreenCoordinator)
    }
}
