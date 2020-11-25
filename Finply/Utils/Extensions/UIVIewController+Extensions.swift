//
//  UIVIewController+Extensions.swift
//  Finply
//
//  Created by Illia Postoienko on 25.11.2020.
//

import UIKit

extension UIViewController {
    
    func preferedStatusBarStyle(for color: UIColor) -> UIStatusBarStyle {

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        
        if !(color.getRed(UnsafeMutablePointer<CGFloat>(mutating: &red),
                          green: UnsafeMutablePointer<CGFloat>(mutating: &green),
                          blue: UnsafeMutablePointer<CGFloat>(mutating: &blue), alpha: nil) ?? false) {
            return .default
        }

        red *= 0.2126
        green *= 0.7152
        blue *= 0.0722
        let luminance = red + green + blue

        return (luminance > 0.6) ? .darkContent : .lightContent
    }
}
