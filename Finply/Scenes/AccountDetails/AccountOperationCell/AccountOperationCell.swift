//
//  AccountOperationCell.swift
//  Finply
//
//  Created by Illia Postoienko on 06.11.2020.
//

import UIKit
import RxSwift
import RxCocoa

final class AccountOperationCell: UITableViewCell, BindableType, NibReusable {
    
    var viewModel: AccountOperationCellViewModelType!
    
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
        super.prepareForReuse()
        bag = DisposeBag()
    }
    
    func bindViewModel() {
        
    }
    
    private func commonInit() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.9803921569, alpha: 1)
        self.selectedBackgroundView = backgroundView
    }
}
