//
//  CurrencyListSeparatorCell.swift
//  Finply
//
//  Created by Illia Postoienko on 17.01.2021.
//

import UIKit

final class CurrencyListSeparatorCell: UITableViewCell, NibReusable {
    
    @IBOutlet private var infoLabel: UILabel!
    
    func set(text: String) {
        infoLabel.text = text
    }
}
