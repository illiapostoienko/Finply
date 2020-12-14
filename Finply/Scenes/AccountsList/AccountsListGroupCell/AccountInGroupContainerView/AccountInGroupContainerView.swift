//
//  AccountInGroupContainerView.swift
//  Finply
//
//  Created by Illia Postoienko on 13.12.2020.
//

import UIKit

struct AccountInGroupContainerItem: Equatable {
    let accountName: String
    let value: String
}

final class AccountInGroupContainerView: UIView, NibBased {
    
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var valueLabel: UILabel!
    
    private var currentItem: AccountInGroupContainerItem?
    
    func set(item: AccountInGroupContainerItem) {
        guard item != currentItem else { return }
        
        currentItem = item
        
        nameLabel.text = item.accountName
        valueLabel.text = item.value
    }
}
