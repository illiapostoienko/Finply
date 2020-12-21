//
//  AccountsListAccountCell.swift
//  Finply
//
//  Created by Illia Postoienko on 27.11.2020.
//

import UIKit
import RxSwift
import RxCocoa

final class AccountsListAccountCell: SwipeableCell, NibReusable, BindableType {
    
    @IBOutlet private var baseCardView: GradientView!
    @IBOutlet private var swipeActionsContainerView: UIView!
    @IBOutlet private var deleteActionButton: UIButton!
    @IBOutlet private var editActionButton: UIButton!
    @IBOutlet private var swipeViewLeadingConstraint: NSLayoutConstraint!
    
    var viewModel: AccountsListAccountCellViewModelType!
    
    private var bag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()

        viewTranslationUpdates = { self.updateSwipeBy(offset: $0) }
        calculateCurrentOffset = { self.swipeViewLeadingConstraint.constant }
        
        swipeThreshold = swipeActionsContainerView.frame.width
        addSwipeRecognizer(to: baseCardView)
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = .clear
        self.selectedBackgroundView = backgroundView
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = DisposeBag()
        swipeViewLeadingConstraint.constant = 0
    }
    
    func updateSwipeBy(offset: CGFloat) {
        swipeViewLeadingConstraint.constant = offset
    }
    
    func bindViewModel() {
        editActionButton.rx.tap
            .bind(to: viewModel.editTap)
            .disposed(by: bag)
        
        deleteActionButton.rx.tap
            .bind(to: viewModel.deleteTap)
            .disposed(by: bag)
    }
}
