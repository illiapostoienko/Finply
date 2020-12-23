//
//  ClearCell.swift
//  Finply
//
//  Created by Illia Postoienko on 23.12.2020.
//

import UIKit

final class ClearCell: UITableViewCell, NibReusable {
    
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    
    func setHeight(_ height: CGFloat) {
        heightConstraint.constant = height
    }
}
