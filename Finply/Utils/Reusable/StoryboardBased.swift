//
//  StoryboardBased.swift
//  Finply
//
//  Created by Illia Postoienko on 30.09.2020.
//

import UIKit

protocol StoryboardBased { }
extension UIViewController: StoryboardBased { }

extension StoryboardBased where Self: UIViewController {

    static func instantiate(isInitial: Bool = true) -> Self {
        let storyboardName = String(describing: self)
        guard let viewController = UIStoryboard(name: storyboardName, bundle: Bundle(for: self)).instantiateInitialViewController(),
            let typedViewController = viewController as? Self else {
            fatalError("Storyboard \(storyboardName) could not be initialized")
        }
        
        return typedViewController
    }
}

extension UIViewController {

    public class func instantiateFromXib(_ xibName: String? = nil) -> Self? {
        let xibName = xibName ?? String(describing: self)
        let bundle = Bundle(for: self)
        guard bundle.path(forResource: xibName, ofType: "nib") != nil else { return nil }
        return Self(nibName: xibName, bundle: bundle)
    }
}
