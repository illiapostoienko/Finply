//
//  HomeScreenViewController.swift
//  Finply
//
//  Created by Illia Postoienko on 30.09.2020.
//

import UIKit
import RxSwift
import RxCocoa

final class HomeScreenViewController: UIViewController, BindableType {
    
    @IBOutlet private var addOperationButton: UIButton!
    @IBOutlet private var editOperationButton: UIButton!
    @IBOutlet private var accountsListButton: UIButton!
    
    var viewModel: HomeScreenViewModelType!
    
    private let bag = DisposeBag()
    
    func bindViewModel() {
        addOperationButton.rx
            .tap
            .bind(to: viewModel.addButtonPressed)
            .disposed(by: bag)
        
        editOperationButton.rx
            .tap
            .bind(to: viewModel.editButtonPressed)
            .disposed(by: bag)
        
        accountsListButton.rx
            .tap
            .bind(to: viewModel.accountsListPressed)
            .disposed(by: bag)
    }
}
