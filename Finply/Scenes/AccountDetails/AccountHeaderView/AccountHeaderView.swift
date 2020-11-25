//
//  AccountHeaderView.swift
//  Finply
//
//  Created by Illia Postoienko on 06.11.2020.
//

import UIKit
import RxSwift
import RxCocoa

final class AccountHeaderView: NibLoadable, BindableType {
    
    //Profile
    @IBOutlet private var profileContainerView: UIView!
    @IBOutlet private var greetingLabel: UILabel!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var profileButton: UIButton!
    
    //Card
    @IBOutlet private var cardView: GradientView!
    @IBOutlet private var cardMaskImageView: UIImageView!
    @IBOutlet private var cardViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private var cardViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private var cardViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet private var accountButton: UIButton!
    @IBOutlet private var editAccountButton: UIButton!
    @IBOutlet private var accountNameLabel: UILabel!
    
    //Main Ballance
    @IBOutlet private var ballanceLabel: UILabel!
    @IBOutlet private var ballanceTopConstraint: NSLayoutConstraint!
    @IBOutlet private var ballanceLeadingConstraint: NSLayoutConstraint!
    
    var viewModel: AccountHeaderViewModelType!
    
    private let bag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cardView.startColor = #colorLiteral(red: 0.6117647059, green: 0.1725490196, blue: 0.9529411765, alpha: 1)
        cardView.endColor = #colorLiteral(red: 0.3019607843, green: 0.4, blue: 0.8745098039, alpha: 1)
    }
    //TODO: add shadows to cards
    
    func bindViewModel() {
        profileButton.rx.tap.bind(to: viewModel.profileTap).disposed(by: bag)
        accountButton.rx.tap.bind(to: viewModel.accountTap).disposed(by: bag)
        editAccountButton.rx.tap.bind(to: viewModel.editAccountTap).disposed(by: bag)
    }
    
    func adjustLayout(by percent: CGFloat) {
        cardViewTopConstraint.constant = 16 - (139 * percent)
        cardViewLeadingConstraint.constant = 42 - (57 * percent)
        cardViewTrailingConstraint.constant = 42 - (57 * percent)
        
        editAccountButton.alpha = 1 - percent * 2
        accountNameLabel.alpha = 1 - percent * 2
        cardMaskImageView.alpha = 1 - percent * 2
        
        ballanceTopConstraint.constant = 129 - (106 * percent)
        
        let width = frame.width
        let ballanceLabelWidth = ballanceLabel.frame.width
        let leadingValueToCenter = (frame.width / 2) - (ballanceLabel.frame.width / 2)
        ballanceLeadingConstraint.constant = 62 + (leadingValueToCenter - 62) * percent
    }
}
