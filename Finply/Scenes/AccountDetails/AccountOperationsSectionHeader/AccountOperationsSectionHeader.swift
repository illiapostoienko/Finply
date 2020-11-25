//
//  AccountOperationsSectionHeader.swift
//  Finply
//
//  Created by Illia Postoienko on 06.11.2020.
//

import UIKit

final class AccountOperationsSectionHeader: UITableViewHeaderFooterView, NibReusable {
    
    @IBOutlet private var dateLabel: UILabel!
    
    func setupDate(_ date: String) {
        dateLabel.text = date
    }
}
