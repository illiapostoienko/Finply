//
//  CurrencyListCell.swift
//  Finply
//
//  Created by Illia Postoienko on 16.01.2021.
//

import UIKit

final class CurrencyListCell: UITableViewCell, NibReusable {
    
    @IBOutlet private var currencyCodeLabel: UILabel!
    @IBOutlet private var currencyNameLabel: UILabel!
    @IBOutlet private var checkImageView: UIImageView!
    
    func setCurrency(_ currency: Currency) {
        currencyCodeLabel.text = currency.rawValue
        currencyNameLabel.text = currency.localized
    }
    
    func setSelected(_ selected: Bool) {
        checkImageView.isHidden = !selected
        currencyCodeLabel.textColor = selected ? #colorLiteral(red: 0.3019607843, green: 0.4, blue: 0.8745098039, alpha: 1) : .label
        currencyCodeLabel.textColor = selected ? #colorLiteral(red: 0.3019607843, green: 0.4, blue: 0.8745098039, alpha: 1) : .label
    }
}
