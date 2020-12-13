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
    
    @IBOutlet private var baseCardView: GradientView!
    
    var viewModel: AccountsListAccountCellViewModelType!
    
    private var bag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = .clear
        self.selectedBackgroundView = backgroundView
    }

    override func prepareForReuse() {
        bag = DisposeBag()
    }
    
    func bindViewModel() {
        
    }
}
