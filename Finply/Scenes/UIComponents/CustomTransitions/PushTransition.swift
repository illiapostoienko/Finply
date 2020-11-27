//
//  PushTransition.swift
//  Finply
//
//  Created by Illia Postoienko on 27.11.2020.
//

import UIKit

final class PushTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    private let initialVc: UIViewController
    
    init(initialVc: UIViewController) {
        self.initialVc = initialVc
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PushTransitionAnimator(type: .present, baseVc: presenting, presentedVc: presented)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PushTransitionAnimator(type: .dismiss, baseVc: initialVc, presentedVc: dismissed)
    }
}

final class PushTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    static let duration: TimeInterval = 0.375
    
    private let type: PresentationType
    private let baseVc: UIViewController
    private let presentedVc: UIViewController
    
    init?(type: PresentationType, baseVc: UIViewController, presentedVc: UIViewController) {
        self.type = type
        self.baseVc = baseVc
        self.presentedVc = presentedVc
        
        guard let window = baseVc.view.window ?? presentedVc.view.window
        else { return nil }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Self.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        guard let fromView = baseVc.view, let toView = presentedVc.view else {
            transitionContext.completeTransition(false)
            return
        }
        
        if type.isPresenting {
            guard let snapshot = presentedVc.view.snapshotView(afterScreenUpdates: true) else {
                transitionContext.completeTransition(false)
                return
            }
            
            toView.isHidden = true
            containerView.addSubview(toView)
            snapshot.frame = CGRect(x: baseVc.view.frame.width, y: 0, width: baseVc.view.frame.width, height: baseVc.view.frame.height)
            containerView.addSubview(snapshot)
            
            UIView.animate(withDuration: Self.duration, animations: {
                snapshot.frame = (transitionContext.finalFrame(for: self.presentedVc))
            }, completion: { _ in
                self.presentedVc.view.isHidden = false
                snapshot.removeFromSuperview()
                transitionContext.completeTransition(true)
            })
        } else {
            guard let snapshot = toView.snapshotView(afterScreenUpdates: true) else {
                transitionContext.completeTransition(false)
                return
            }

            snapshot.frame = baseVc.view.frame
            containerView.addSubview(snapshot)
            presentedVc.view.isHidden = true
            
            UIView.animate(withDuration: Self.duration, animations: {
                snapshot.frame = CGRect(x: self.baseVc.view.frame.width, y: 0, width: self.baseVc.view.frame.width, height: self.baseVc.view.frame.height)
            }, completion: { _ in
                //self.baseVc.view.isHidden = false
                snapshot.removeFromSuperview()
                transitionContext.completeTransition(true)
            })
        }
    }
}

enum PresentationType {
    
    case present
    case dismiss
    
    var isPresenting: Bool {
        return self == .present
    }
}
