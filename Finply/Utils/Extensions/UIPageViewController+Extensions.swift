//
//  UIPageViewController+Extensions.swift
//  Finply
//
//  Created by Illia Postoienko on 26.11.2020.
//

import UIKit

extension UIPageViewController {

    func setScrollEnabled(_ state: Bool) {
        for subview in view.subviews {
            if let scrollview = subview as? UIScrollView {
                scrollview.isScrollEnabled = state
            }
        }
    }
}
