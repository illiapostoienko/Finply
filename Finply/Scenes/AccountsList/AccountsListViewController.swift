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
    
    var viewModel: AccountsListViewModelType!
    
    private let bag = DisposeBag()
    
    func bindViewModel() {

    }
}
