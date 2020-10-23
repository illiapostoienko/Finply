//
//  AddEditOperationViewController.swift
//  Finply
//
//  Created by Illia Postoienko on 30.09.2020.
//

import UIKit
import RxSwift
import RxCocoa

final class AddEditOperationViewController: UIViewController, BindableType {
    
    @IBOutlet private var cancelButton: UIButton!
    
    var viewModel: AddEditOperationViewModelType!
    
    private let bag = DisposeBag()
    
    func bindViewModel() {
        cancelButton.rx
            .tap
            .bind(to: viewModel.cancelTapped)
            .disposed(by: bag)
    }
}
