//
//  AccountsSelectionCell.swift
//  Finply
//
//  Created by Illia Postoienko on 21.12.2020.
//

import UIKit
import RxSwift

final class AccountsSelectionCell: UITableViewCell, BindableType, NibReusable {
    
    @IBOutlet private var accountsContainer: AccountsSelectionContainerView!
    
    var viewModel: AccountsSelectionCellViewModelType!
    
    private let bag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        removeSeparator()
    }
    
    func bindViewModel() {
        viewModel.allAccountItems
            .bind(to: accountsContainer.rx.items)
            .disposed(by: bag)
    }
}
