//
//  SwipeableCell.swift
//  Finply
//
//  Created by Illia Postoienko on 18.12.2020.
//

import Foundation
import UIKit
import RxSwift

@objc protocol SwipeableCellDelegate: class {
    @objc optional func didStartSwiping(_ cell: SwipeableCell)
    @objc optional func didSwipe(_ cell: SwipeableCell)
}

class SwipeableCell: UITableViewCell {
    
    enum SwipeableCellState {
        case initial
        case leftEnd
        case rightEnd
    }
    
    public enum SwipeableCellDirection {
        case both
        case right
        case left
    }
    
    weak var swipeDelegate: SwipeableCellDelegate?
    
    fileprivate(set) var swipeState: SwipeableCellState = .initial
    var swipeDirection: SwipeableCellDirection = .left
    var swipeThreshold: CGFloat = 100
    var swipePanElasticityFactor: CGFloat = 0.7
    var swipeAnimationDuration: Double = 0.3
    
    // To Set in view
    var viewTranslationUpdates: (_ percent: CGFloat) -> Void = { _ in }
    var calculateCurrentOffset: () -> CGFloat = { 0 }
    
    func addSwipeRecognizer(to view: UIView) {
        let panGestureRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleSwipePan(_:)))
        panGestureRecognizer.delegate = self
        view.addGestureRecognizer(panGestureRecognizer)
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        swipeState = .initial
    }

    @objc func handleSwipePan(_ panGestureRecognizer: UIPanGestureRecognizer) {
        let translation: CGPoint = panGestureRecognizer.translation(in: panGestureRecognizer.view)
        var panOffset: CGFloat = translation.x
        
        //elasticity
        if abs(translation.x) > swipeThreshold {
            let offset: CGFloat = abs(translation.x)
            panOffset = (offset - ((offset - swipeThreshold) * swipePanElasticityFactor)) * (translation.x < 0 ? -1.0 : 1.0)
        }
        
        if panGestureRecognizer.state == .began && panGestureRecognizer.numberOfTouches > 0 {
            let newOffset = calculateCurrentOffset()
            
            panGestureRecognizer.setTranslation(CGPoint(x: newOffset, y: 0), in: panGestureRecognizer.view)
            
            swipeDelegate?.didStartSwiping?(self)
            animateContent(for: newOffset)
        }
        else {
            if panGestureRecognizer.state == .changed && panGestureRecognizer.numberOfTouches > 0 {
                animateContent(for: panOffset)
            }
            else {
                resetCellPosition()
            }
        }
    }
    
    private func animateContent(for offset: CGFloat) {
        if (offset > 0 && swipeDirection == .right)
            || (offset < 0 && swipeDirection == .left)
            || swipeDirection == .both {

            let previousState = swipeState
            if offset >= self.swipeThreshold / 2 {
                self.swipeState = .rightEnd
            }
            else if offset < -self.swipeThreshold / 2 {
                self.swipeState = .leftEnd
            }
            else {
                self.swipeState = .initial
            }

            self.swipeDelegate?.didSwipe?(self)
            
            self.viewTranslationUpdates(offset)
        }
        else {
            if (offset > 0 && swipeDirection == .left)
                || (offset < 0 && swipeDirection == .right) {

                self.viewTranslationUpdates(0)
            }
        }
    }
    
    func resetCellPosition(toInitial: Bool = false) {
        UIView.animate(withDuration: swipeAnimationDuration, delay: 0, options: .allowUserInteraction, animations: { [unowned self] in
            
            let state = toInitial ? .initial : swipeState
            let desiredOffset: CGFloat
            switch state {
            case .initial: desiredOffset = 0
            case .leftEnd: desiredOffset = -swipeThreshold
            case .rightEnd: desiredOffset = swipeThreshold
            }
            self.viewTranslationUpdates(desiredOffset)
            self.layoutIfNeeded()
        },
        completion: nil)
    }
    
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKind(of: UIPanGestureRecognizer.self),
           let pan = gestureRecognizer as? UIPanGestureRecognizer {
            let translation: CGPoint = pan.translation(in: self.superview)
            return (abs(translation.x) / abs(translation.y) > 1) ? true : false
        }
        return false
    }
}
