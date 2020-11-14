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
    @IBOutlet private var accountButton: UIButton!
    @IBOutlet private var editAccountButton: UIButton!
    
    var viewModel: AccountHeaderViewModelType!
    
    private let bag = DisposeBag()
    
    //TODO: add shadows to cards
    
    func bindViewModel() {
        profileButton.rx.tap.bind(to: viewModel.profileTap).disposed(by: bag)
        accountButton.rx.tap.bind(to: viewModel.accountTap).disposed(by: bag)
        editAccountButton.rx.tap.bind(to: viewModel.editAccountTap).disposed(by: bag)
    }
    
    func adjustLayout(by percent: CGFloat) {
        alpha = 1 - percent
    }
}
