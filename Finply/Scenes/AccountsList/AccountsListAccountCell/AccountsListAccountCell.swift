//
//  AccountsListAccountCell.swift
//  Finply
//
//  Created by Illia Postoienko on 27.11.2020.
//

import UIKit
import RxSwift
import RxCocoa

final class AccountsListAccountCell: UITableViewCell, NibReusable, BindableType {
    
    var viewModel: AccountsListAccountCellViewModelType!
    
    private var bag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func prepareForReuse() {
        bag = DisposeBag()
    }
    
    func bindViewModel() {
        
    }
    
    private func commonInit() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = .clear
        self.selectedBackgroundView = backgroundView
    }
}
