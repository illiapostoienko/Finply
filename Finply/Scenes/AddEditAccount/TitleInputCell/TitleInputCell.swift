//
//  TitleInputCell.swift
//  Finply
//
//  Created by Illia Postoienko on 28.11.2020.
//

import Foundation
import UIKit

final class TitleInputCell: UITableViewCell, BindableType, NibReusable {
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var textFieldBaseView: UIView!
    @IBOutlet private var inputTextField: UITextField!
    
    var viewModel: TitleInputCellViewModelType!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textFieldBaseView.makeBorder(width: 1, color: #colorLiteral(red: 0.7137254902, green: 0.7764705882, blue: 0.8509803922, alpha: 0.5))
        removeSeparator()
    }
    
    func bindViewModel() {
        
    }
}

extension TitleInputCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
