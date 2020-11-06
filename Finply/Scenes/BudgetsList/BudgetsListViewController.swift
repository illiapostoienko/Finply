//  
//  BudgetsListViewController.swift
//  Finply
//
//  Created by Illia Postoienko on 06.11.2020.
//

import UIKit
import RxSwift
import RxCocoa

final class BudgetsListViewController: UIViewController, BindableType {
    
    var viewModel: BudgetsListViewModelType!
    
    private let bag = DisposeBag()
    
    func bindViewModel() {

    }
}
