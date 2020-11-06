//  
//  PlanningListViewController.swift
//  Finply
//
//  Created by Illia Postoienko on 06.11.2020.
//

import UIKit
import RxSwift
import RxCocoa

final class PlanningListViewController: UIViewController, BindableType {
    
    var viewModel: PlanningListViewModelType!
    
    private let bag = DisposeBag()
    
    func bindViewModel() {

    }
}
