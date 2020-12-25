//
//  PresentationDelegate.swift
//  Finply
//
//  Created by Illia Postoienko on 25.12.2020.
//

import Foundation
import UIKit

protocol PresentationDelegate: class {
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?)
}

extension UIViewController: PresentationDelegate {}
