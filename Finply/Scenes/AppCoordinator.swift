//
//  AppCoordinator.swift
//  Finply
//
//  Created by Illia Postoienko on 30.09.2020.
//

import UIKit
import Dip
import RxSwift
import RxSwiftExt

enum FinplyContainerPage {
    case budgets
    case accountDetails
    case planning
}

final class AppCoordinator: BaseCoordinator<Void> {

    let window: UIWindow
    let dependencyContainer: DependencyContainer
    let bag = DisposeBag()
    
    private var containerViewController: UIViewController!
    
    private var pageViewController: UIPageViewController!
    private var accountDetailsViewController: AccountDetailsViewController!
    private var budgetsViewController: BudgetsListViewController!
    private var planningViewController: PlanningListViewController!
    
    init(window: UIWindow, dependencyContainer: DependencyContainer) {
        self.window = window
        self.dependencyContainer = dependencyContainer
        
        super.init()
    }

    override func start() -> Observable<Void> {
        
        let accountDetailsCoordinator = AccountDetailsCoordinator(dependencyContainer: dependencyContainer)
        let planningCoordinator = PlanningListCoordinator(dependencyContainer: dependencyContainer)
        let budgetsCoordinator = BudgetsListCoordinator(dependencyContainer: dependencyContainer)
        
        accountDetailsViewController = accountDetailsCoordinator.viewController
        budgetsViewController = budgetsCoordinator.viewController
        planningViewController = planningCoordinator.viewController
        
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        
        pageViewController.dataSource = self
        pageViewController.setViewControllers([accountDetailsViewController], direction: .forward, animated: false, completion: nil)
        
        containerViewController = UIViewController()
        containerViewController.addChild(pageViewController)
        pageViewController.view.frame = containerViewController.view.frame
        containerViewController.view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: containerViewController)
        
        window.rootViewController = containerViewController
        window.makeKeyAndVisible()

        return Observable.merge(coordinate(to: accountDetailsCoordinator),
                                coordinate(to: planningCoordinator),
                                coordinate(to: budgetsCoordinator))
    }
    
    private func viewController(before viewController: UIViewController) -> UIViewController? {
        guard let page = self.page(for: viewController),
            let previousPage = page.pageBefore() else { return nil }
        
        return self.viewController(for: previousPage)
    }
    
    private func viewController(after viewController: UIViewController) -> UIViewController? {
        guard let page = self.page(for: viewController),
            let nextPage = page.pageAfter() else { return nil }
        
        return self.viewController(for: nextPage)
    }
    
    private func viewController(for page: FinplyContainerPage) -> UIViewController {
        switch page {
        case .budgets: return budgetsViewController
        case .accountDetails: return accountDetailsViewController
        case .planning: return planningViewController
        }
    }
    
    private func page(for viewController: UIViewController) -> FinplyContainerPage? {
        switch viewController {
        case is BudgetsListViewController: return .budgets
        case is AccountDetailsViewController: return .accountDetails
        case is PlanningListViewController: return .planning
        default: return nil
        }
    }
}

extension AppCoordinator: UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return self.viewController(before: viewController)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return self.viewController(after: viewController)
    }
}

extension FinplyContainerPage {
    func pageBefore() -> FinplyContainerPage? {
        switch self {
        case .budgets: return nil
        case .accountDetails: return .budgets
        case .planning: return .accountDetails
        }
    }
    
    func pageAfter() -> FinplyContainerPage? {
        switch self {
        case .budgets: return .accountDetails
        case .accountDetails: return .planning
        case .planning: return nil
        }
    }
}
