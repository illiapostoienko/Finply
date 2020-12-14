//
//  AccountsListGroupCell.swift
//  Finply
//
//  Created by Illia Postoienko on 27.11.2020.
//

import UIKit
import RxSwift
import RxCocoa

final class AccountsListGroupCell: UITableViewCell, NibReusable, BindableType {
    
    @IBOutlet private var backgroundGradientView: GradientView!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var accountsInGroupContainerView: AccountsInGroupContainerView!
    
    var viewModel: AccountsListGroupCellViewModelType!
    
    private var bag = DisposeBag()
    
    override func prepareForReuse() {
        bag = DisposeBag()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        accountsInGroupContainerView
            .setup(with: [
                AccountInGroupContainerItem(accountName: "Monobank", value: "$324.3"),
                AccountInGroupContainerItem(accountName: "Monobank White", value: "$3134.3"),
                AccountInGroupContainerItem(accountName: "Raiffeisen", value: "$42243.5")
            ])
    }
    
    func bindViewModel() {
        
    }
}
