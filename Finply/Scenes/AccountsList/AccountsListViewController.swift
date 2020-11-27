//
//  AccountsListViewController.swift
//  Finply
//
//  Created by Illia Postoienko on 23.10.2020.
//

import UIKit
import RxSwift
import RxCocoa

final class AccountsListViewController: UIViewController, BindableType {
    
    @IBOutlet private var backButton: UIButton!
    
    var viewModel: AccountsListViewModelType!
    var transitionFrame: CGRect = .zero
    
    private let bag = DisposeBag()
    
    func bindViewModel() {
        backButton.rx.tap.bind(to: viewModel.backButtonTap).disposed(by: bag)
    }
}
