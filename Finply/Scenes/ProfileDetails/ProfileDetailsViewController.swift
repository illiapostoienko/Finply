//  
//  ProfileDetailsViewController.swift
//  Finply
//
//  Created by Illia Postoienko on 10.11.2020.
//

import UIKit
import RxSwift
import RxCocoa

final class ProfileDetailsViewController: UIViewController, BindableType {
    
    var viewModel: ProfileDetailsViewModelType!
    
    private let bag = DisposeBag()
    
    func bindViewModel() {

    }
}
