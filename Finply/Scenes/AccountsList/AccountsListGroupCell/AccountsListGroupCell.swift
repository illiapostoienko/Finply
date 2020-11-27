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
    
    var viewModel: AccountsListGroupCellViewModelType!
    
    private var bag = DisposeBag()
    
    override func prepareForReuse() {
        bag = DisposeBag()
    }
    
    func bindViewModel() {
        
    }
}
