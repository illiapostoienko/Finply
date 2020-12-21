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
    case budgetsList
    case accountDetails
    case planningList
}

final class AppCoordinator: BaseCoordinator<Void> {

    let window: UIWindow
    let dependencyContainer: DependencyContainer
    private let bag = DisposeBag()
    
    private let containerViewController: UIViewController = UIViewController()
    private let pageViewController: UIPageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
    private let accountDetailsVc: AccountDetailsViewController = AccountDetailsViewController.instantiate()
    private let budgetsListVc: BudgetsListViewController = BudgetsListViewController.instantiate()
    private let planningListVc: PlanningListViewController = PlanningListViewController.instantiate()
    
    init(window: UIWindow, dependencyContainer: DependencyContainer) {
        self.window = window
        self.dependencyContainer = dependencyContainer
        super.init()
    }
    
    override func start() -> Observable<Void> {

        let accountDetailsCoordinator = AccountDetailsCoordinator(accountDetailsVc: accountDetailsVc, basePageViewController: pageViewController, dependencyContainer: dependencyContainer)
        let budgetsCoordinator = BudgetsListCoordinator(budgetsListVc: budgetsListVc, dependencyContainer: dependencyContainer)
        let planningCoordinator = PlanningListCoordinator(planningListVc: planningListVc, dependencyContainer: dependencyContainer)
        
        pageViewController.dataSource = self
        pageViewController.setViewControllers([accountDetailsVc], direction: .forward, animated: false, completion: nil)

        containerViewController.view.backgroundColor = #colorLiteral(red: 0.9803921569, green: 0.9921568627, blue: 1, alpha: 1)
        
        containerViewController.addChild(pageViewController)
        containerViewController.view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: containerViewController)
        
        containerViewController.view.translatesAutoresizingMaskIntoConstraints = false
        containerViewController.view.addFilledSubview(pageViewController.view)
        
        window.rootViewController = containerViewController
        window.makeKeyAndVisible()

        return Observable.merge(coordinate(to: accountDetailsCoordinator),
                                coordinate(to: planningCoordinator),
                                coordinate(to: budgetsCoordinator))
    }
}

extension AppCoordinator: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let page = self.page(for: viewController),
              let previousPage = page.pageBefore() else { return nil }
        
        return self.viewController(for: previousPage)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let page = self.page(for: viewController),
              let nextPage = page.pageAfter() else { return nil }
        
        return self.viewController(for: nextPage)
    }
    
    private func viewController(for page: FinplyContainerPage) -> UIViewController {
        switch page {
        case .budgetsList: return budgetsListVc
        case .accountDetails: return accountDetailsVc
        case .planningList: return planningListVc
        }
    }
    
    private func page(for viewController: UIViewController) -> FinplyContainerPage? {
        switch viewController {
        case is BudgetsListViewController: return .budgetsList
        case is AccountDetailsViewController: return .accountDetails
        case is PlanningListViewController: return .planningList
        default: return nil
        }
    }
}

extension FinplyContainerPage {
    func pageBefore() -> FinplyContainerPage? {
        switch self {
        case .budgetsList: return nil
        case .accountDetails: return .budgetsList
        case .planningList: return .accountDetails
        }
    }
    
    func pageAfter() -> FinplyContainerPage? {
        switch self {
        case .budgetsList: return .accountDetails
        case .accountDetails: return .planningList
        case .planningList: return nil
        }
    }
}
