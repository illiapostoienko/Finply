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
    @IBOutlet private var iconImageView: UIImageView!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var valueLabel: UILabel!
    @IBOutlet private var swipeActionsContainerView: UIView!
    @IBOutlet private var deleteActionButton: UIButton!
    @IBOutlet private var editActionButton: UIButton!
    @IBOutlet private var swipeViewLeadingConstraint: NSLayoutConstraint!
    
    weak var presentationDelegate: PresentationDelegate?
    
    var viewModel: AccountsListAccountCellViewModelType!
    
    private var bag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()

        viewTranslationUpdates = { [unowned self] in self.updateSwipeBy(offset: $0) }
        calculateCurrentOffset = { [unowned self] in self.swipeViewLeadingConstraint.constant }
        
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
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Delete Account", message: "Are you sure to delete this Account", preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let delete = UIAlertAction(title: "Delete", style: .destructive) { [unowned self] _ in
            self.resetCellPosition(toInitial: true)
            self.viewModel.deleteTap.onNext(())
        }
        alert.addAction(cancel)
        alert.addAction(delete)
        
        presentationDelegate?.present(alert, animated: true, completion: nil)
    }
    
    func bindViewModel() {
        editActionButton.rx.tap
            .do(onNext: { [unowned self] in self.resetCellPosition(toInitial: true) })
            .bind(to: viewModel.editTap)
            .disposed(by: bag)
        
        viewModel.accountModel.map{ $0.name }
            .bind(to: nameLabel.rx.text)
            .disposed(by: bag)
    }
}
