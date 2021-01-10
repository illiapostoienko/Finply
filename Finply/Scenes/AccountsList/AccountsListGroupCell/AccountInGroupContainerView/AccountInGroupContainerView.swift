//
//  AccountInGroupContainerView.swift
//  Finply
//
//  Created by Illia Postoienko on 13.12.2020.
//

import UIKit

struct AccountInGroupContainerItem: Equatable {
    let accountName: String
    let valueInCents: Int
    let currency: Currency
}

final class AccountInGroupContainerView: UIView, NibBased {
    
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var valueLabel: UILabel!
    
    private var currentItem: AccountInGroupContainerItem?
    private let formatter = CurrencyFormatter()
    
    func set(item: AccountInGroupContainerItem) {
        guard item != currentItem else { return }
        
        currentItem = item
        
        nameLabel.text = item.accountName
        
        formatter.currency = item.currency
        let doubleValue = Double(item.valueInCents) / Double(100)
        valueLabel.text = formatter.string(from: doubleValue)
    }
}
