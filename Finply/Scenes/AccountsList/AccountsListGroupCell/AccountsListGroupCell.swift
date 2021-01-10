//
//  AccountsListGroupCell.swift
//  Finply
//
//  Created by Illia Postoienko on 27.11.2020.
//

import UIKit
import RxSwift
import RxCocoa
import SwipeCellKit

final class AccountsListGroupCell: SwipeTableViewCell, NibReusable, BindableType {
    
    @IBOutlet private var baseIconView: GradientView!
    @IBOutlet private var iconImageView: UIImageView!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var valueLabel: UILabel!
    @IBOutlet private var accountsInGroupContainerView: AccountsInGroupContainerView!
    @IBOutlet private var orderLabel: UILabel!
    
    var viewModel: AccountsListGroupCellViewModelType!
    
    private var bag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = DisposeBag()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        accountsInGroupContainerView
            .setup(with: [
                AccountInGroupContainerItem(accountName: "Monobank", value: "$324.3"),
                AccountInGroupContainerItem(accountName: "Monobank White", value: "$3134.3"),
                AccountInGroupContainerItem(accountName: "Raiffeisen", value: "$42243.5")
            ])
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = .clear
        self.selectedBackgroundView = backgroundView
    }
    
    func bindViewModel() {
        viewModel.accountGroupModel.map{ $0.name }
            .bind(to: nameLabel.rx.text)
            .disposed(by: bag)
        
        viewModel.accountGroupModel.map{ String($0.order) }
            .bind(to: orderLabel.rx.text)
            .disposed(by: bag)
    }
}
