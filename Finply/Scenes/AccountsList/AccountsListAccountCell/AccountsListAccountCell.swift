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
        viewModel.accountModel.map{ $0.name }
            .bind(to: nameLabel.rx.text)
            .disposed(by: bag)
        
        viewModel.accountModel.map{ String($0.order) }
            .bind(to: orderLabel.rx.text)
            .disposed(by: bag)
    }
}
