//
//  AccountsSelectionCell.swift
//  Finply
//
//  Created by Illia Postoienko on 21.12.2020.
//

import Foundation
import UIKit

final class AccountsSelectionCell: UITableViewCell, BindableType, NibReusable {
    
    var viewModel: AccountsSelectionCellViewModelType!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        removeSeparator()
    }
    
    func bindViewModel() {
        
    }
}
