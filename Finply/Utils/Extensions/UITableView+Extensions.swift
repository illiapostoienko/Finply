//
//  UITableView+Extensions.swift
//  Finply
//
//  Created by Illia Postoienko on 13.11.2020.
//

import UIKit

public extension UITableView {

    var indexesOfVisibleSections: [Int] {
        var visibleSectionIndexes = [Int]()
        
        for i in 0..<numberOfSections {
            let headerRect = self.style == .plain ? rect(forSection: i) : rectForHeader(inSection: i)
            
            let visiblePartOfTableView: CGRect = CGRect(x: contentOffset.x, y: contentOffset.y, width: bounds.size.width, height: bounds.size.height)
            if visiblePartOfTableView.intersects(headerRect) { visibleSectionIndexes.append(i) }
        }
        
        return visibleSectionIndexes
    }

    var visibleSectionHeaders: [UITableViewHeaderFooterView] {
        var visibleSections = [UITableViewHeaderFooterView]()
        indexesOfVisibleSections.forEach{
            if let sectionHeader = headerView(forSection: $0) {
                visibleSections.append(sectionHeader)
            }
        }
        return visibleSections
    }
}
