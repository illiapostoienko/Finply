//
//  AccountHeaderView.swift
//  Finply
//
//  Created by Illia Postoienko on 06.11.2020.
//

import UIKit
import RxSwift
import RxCocoa

final class AccountHeaderView: NibLoadable, BindableType {
    
    @IBOutlet private var greetingLabel: UILabel!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var profileButton: UIButton!
    @IBOutlet private var cardButton: UIButton!
    
    var viewModel: AccountHeaderViewModelType!
    
    let bag = DisposeBag()
    
    func bindViewModel() {
        profileButton.rx
            .tap
            .bind(to: viewModel.profileTap)
            .disposed(by: bag)
        
        cardButton.rx
            .tap
            .bind(to: viewModel.cardTap)
            .disposed(by: bag)
    }
}
