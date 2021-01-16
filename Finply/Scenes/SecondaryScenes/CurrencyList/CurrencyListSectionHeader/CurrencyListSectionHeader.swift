//
//  CurrencyListSectionHeader.swift
//  Finply
//
//  Created by Illia Postoienko on 16.01.2021.
//

import UIKit

final class CurrencyListSectionHeader: UITableViewHeaderFooterView, NibReusable {
    
    @IBOutlet private var setTextLabel: UILabel!

    func setupText(_ text: String) {
        setTextLabel.text = text
    }
}
