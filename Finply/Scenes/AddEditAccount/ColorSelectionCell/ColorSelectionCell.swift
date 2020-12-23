//
//  ColorSelectionCell.swift
//  Finply
//
//  Created by Illia Postoienko on 21.12.2020.
//

import Foundation
import UIKit

final class ColorSelectionCell: UITableViewCell, BindableType, NibReusable {
    
    var viewModel: ColorSelectionCellViewModelType!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setSelectionBackgroundColor(.clear)
    }
    
    func bindViewModel() {
        
    }
}
