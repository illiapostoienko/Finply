//
//  UITableViewCell+Extension.swift
//  Finply
//
//  Created by Illia Postoienko on 21.12.2020.
//

import UIKit

extension UITableViewCell {
    
    func removeSeparator() {
        separatorInset = UIEdgeInsets(top: 0, left: 500, bottom: 0, right: 0)
    }
    
    func setSelectionBackgroundColor(_ color: UIColor) {
        let backgroundView = UIView()
        backgroundView.backgroundColor = color
        self.selectedBackgroundView = backgroundView
    }
}
