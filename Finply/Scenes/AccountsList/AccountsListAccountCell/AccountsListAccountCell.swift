//
//  AccountsListAccountCell.swift
//  Finply
//
//  Created by Illia Postoienko on 27.11.2020.
//

import UIKit
import RxSwift
import RxCocoa
import SwipeCellKit

final class AccountsListAccountCell: SwipeTableViewCell, NibReusable, BindableType {
    
    @IBOutlet private var baseIconView: GradientView!
    @IBOutlet private var iconImageView: UIImageView!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var valueLabel: UILabel!
    @IBOutlet private var orderLabel: UILabel!
    
    var viewModel: AccountsListAccountCellViewModelType!
    
    private let formatter = CurrencyFormatter()
    private var bag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = .clear
        self.selectedBackgroundView = backgroundView
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = DisposeBag()
    }
    
    func bindViewModel() {        
        viewModel.account.map{ $0.name }
            .bind(to: nameLabel.rx.text)
            .disposed(by: bag)
        
        viewModel.account.map{ String($0.order) }
            .bind(to: orderLabel.rx.text)
            .disposed(by: bag)
        
        viewModel.account
            .map{ [unowned self] account -> String? in
                self.formatter.currency = account.currency
                let doubleValue = Double(account.calculatedValueInCents) / Double(100)
                return self.formatter.string(from: doubleValue)
            }
            .bind(to: valueLabel.rx.text)
            .disposed(by: bag)
    }
}
