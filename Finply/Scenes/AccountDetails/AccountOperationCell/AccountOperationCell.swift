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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = DisposeBag()
    }
    
    func bindViewModel() {
        
    }
}
