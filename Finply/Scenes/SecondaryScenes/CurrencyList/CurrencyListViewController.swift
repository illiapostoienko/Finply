//  
//  CurrencyListViewController.swift
//  Finply
//
//  Created by Illia Postoienko on 21.12.2020.
//

import UIKit
import RxSwift
import RxCocoa

final class CurrencyListViewController: UIViewController, BindableType {
    
    var viewModel: CurrencyListViewModelType!
    
    private let bag = DisposeBag()
    
    func bindViewModel() {

    }
}
