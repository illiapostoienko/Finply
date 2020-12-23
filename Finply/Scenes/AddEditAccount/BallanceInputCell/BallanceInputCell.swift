//
//  BallanceInputCell.swift
//  Finply
//
//  Created by Illia Postoienko on 21.12.2020.
//

import UIKit
import RxSwift

final class BallanceInputCell: UITableViewCell, BindableType, NibReusable {
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var textFieldBaseView: UIView!
    @IBOutlet private var inputTextField: UITextField!
    @IBOutlet private var currencyButton: UIButton!
    
    var viewModel: BallanceInputCellViewModelType!
    
    private let bag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textFieldBaseView.makeBorder(width: 1, color: #colorLiteral(red: 0.7137254902, green: 0.7764705882, blue: 0.8509803922, alpha: 0.5))
        removeSeparator()
    }
    
    func bindViewModel() {
        currencyButton.rx.tap
            .bind(to: viewModel.currencyTapped)
            .disposed(by: bag)
    }
}
