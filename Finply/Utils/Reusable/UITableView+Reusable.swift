//
//  UITableView+Reusable.swift
//  Finply
//
//  Created by Illia Postoienko on 30.09.2020.
//

import UIKit

extension UITableView {
    
    final func register<T: UITableViewCell>(cellType: T.Type)
        where T: Reusable & NibBased {
            self.register(cellType.nib, forCellReuseIdentifier: cellType.reuseIdentifier)
    }
    
    final func register<T: UITableViewCell>(cellType: T.Type)
        where T: Reusable {
            self.register(cellType.self, forCellReuseIdentifier: cellType.reuseIdentifier)
    }
    
    final func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath, cellType: T.Type = T.self) -> T
        where T: Reusable {
            guard let cell = self.dequeueReusableCell(withIdentifier: cellType.reuseIdentifier, for: indexPath) as? T else {
                fatalError(
                    "Failed to dequeue a cell with identifier \(cellType.reuseIdentifier) matching type \(cellType.self). ")
            }
            return cell
    }
    
    final func register<T: UITableViewHeaderFooterView>(headerFooterViewType: T.Type)
        where T: Reusable & NibBased {
            self.register(headerFooterViewType.nib, forHeaderFooterViewReuseIdentifier: headerFooterViewType.reuseIdentifier)
    }
    
    final func register<T: UITableViewHeaderFooterView>(headerFooterViewType: T.Type)
        where T: Reusable {
            self.register(headerFooterViewType.self, forHeaderFooterViewReuseIdentifier: headerFooterViewType.reuseIdentifier)
    }
    
    final func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(_ viewType: T.Type = T.self) -> T
        where T: Reusable {
            guard let view = self.dequeueReusableHeaderFooterView(withIdentifier: viewType.reuseIdentifier) as? T else {
                fatalError(
                    "Failed to dequeue a header/footer with identifier \(viewType.reuseIdentifier) "
                        + "matching type \(viewType.self). ")
            }
            return view
    }
}
