//
//  ClearTableViewCell.swift
//  Finply
//
//  Created by Illia Postoienko on 19.11.2020.
//

import Foundation
import UIKit

final class ClearTableViewCell: UITableViewCell, NibReusable {
    
    @IBOutlet private var clearView: UIView!
    @IBOutlet private var clearViewHeightConstraint: NSLayoutConstraint!
    
    func update(height: CGFloat) {
        clearViewHeightConstraint.constant = height
        layoutIfNeeded()
    }
}
