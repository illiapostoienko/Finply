//
//  IconSelectionCell.swift
//  Finply
//
//  Created by Illia Postoienko on 21.12.2020.
//

import Foundation
import UIKit

final class IconSelectionCell: UITableViewCell, BindableType, NibReusable {
    
    var viewModel: IconSelectionCellViewModelType!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setSelectionBackgroundColor(.clear)
    }
    
    func bindViewModel() {
        
    }
}
