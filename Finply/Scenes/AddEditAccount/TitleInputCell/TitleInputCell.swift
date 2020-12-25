//
//  TitleInputCell.swift
//  Finply
//
//  Created by Illia Postoienko on 28.11.2020.
//

import UIKit
import RxSwift
import RxCocoa

final class TitleInputCell: UITableViewCell, BindableType, NibReusable {
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var textFieldBaseView: UIView!
    @IBOutlet private var inputTextField: UITextField!
    
    var viewModel: TitleInputCellViewModelType!
    
    private let bag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textFieldBaseView.makeBorder(width: 1, color: #colorLiteral(red: 0.7137254902, green: 0.7764705882, blue: 0.8509803922, alpha: 0.5))
        removeSeparator()
    }
    
    func bindViewModel() {
        (inputTextField.rx.text.orEmpty <-> viewModel.currentName).disposed(by: bag)
    }
}

extension TitleInputCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
