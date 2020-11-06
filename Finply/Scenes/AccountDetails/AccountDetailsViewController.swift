//  
//  AccountDetailsViewController.swift
//  Finply
//
//  Created by Illia Postoienko on 06.11.2020.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class AccountDetailsViewController: UIViewController {
    
    @IBOutlet private var detailsStackView: UIStackView!
    @IBOutlet private var accountHeaderView: AccountHeaderView!
    @IBOutlet private var monthDetailsView: AccountMonthDetailsView!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var addOperationButton: UIButton!
    
    @IBOutlet private var tableViewContainerTopConstraint: NSLayoutConstraint!
    @IBOutlet private var tableViewBackgroundViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private var addOperationButtonTopConstraint: NSLayoutConstraint!
    
    var viewModel: AccountDetailsViewModelType!
    
    private var dataSource: RxTableViewSectionedAnimatedDataSource<AccountOperationsTableSection>!
    private let bag = DisposeBag()
    
    private let tableViewTopMinConstant: CGFloat = 70
    
    lazy var sectionDateFormatter: DateFormatter =  {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
}

// MARK: - Bindings
extension AccountDetailsViewController: BindableType {
    
    func bindViewModel() {
        accountHeaderView.bind(to: viewModel.accountHeaderViewModel)
        monthDetailsView.bind(to: viewModel.accountMonthDetailsViewModel)
        
        viewModel
            .dataSource
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
    }
}

// MARK: - Table View
extension AccountDetailsViewController: UIScrollViewDelegate {
    
    private func setupTableView() {
        tableView.dataSource = nil
        tableView.register(cellType: AccountOperationCell.self)
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderHeight = 20
        tableView.tableFooterView = UIView()

        tableView.rx
            .setDelegate(self)
            .disposed(by: bag)
        
        dataSource = RxTableViewSectionedAnimatedDataSource(
            animationConfiguration: AnimationConfiguration(insertAnimation: .fade,
                                                           reloadAnimation: .fade,
                                                           deleteAnimation: .fade),
            configureCell: { dataSource, tableView, indexPath, _ in
                switch dataSource[indexPath] {
                    
                case .operation(let viewModel):
                    var cell = tableView.dequeueReusableCell(for: indexPath) as AccountOperationCell
                    cell.bind(to: viewModel)
                    return cell
                }
        },
        titleForHeaderInSection: { dataSource, indexPath in
            let section = dataSource[indexPath]
            return section.titleDate.map{ self.sectionDateFormatter.string(from: $0) }
        })
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentValue = calculateCurrentValue(contentOffsetY: scrollView.contentOffset.y)
        let maxValue = calculateMaxValue()
        
        guard currentValue < 0 else {
            tableViewContainerTopConstraint.constant = 0
            return
        }
        
        guard currentValue > -maxValue else {
            tableViewContainerTopConstraint.constant = -maxValue
            return
        }
        
        tableViewContainerTopConstraint.constant = currentValue
        tableView.contentOffset = .zero
        
        let percent = currentValue / maxValue
        //walletHeaderView.adjustView(by: abs(percent))
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let currentValue = calculateCurrentValue(contentOffsetY: scrollView.contentOffset.y)
        let maxValue = calculateMaxValue()
        
        let percent = currentValue / maxValue
        
        guard (-1...0) ~= percent else { return }
        
        tableViewContainerTopConstraint.constant = (-0.5...0) ~= percent ? 0 : -calculateMaxValue()
        
        let headerViewAdjustment: CGFloat = (-0.5...0) ~= percent ? 0 : 1
        //walletHeaderView.adjustView(by: headerViewAdjustment)
        
        UIView.animate(withDuration: 0.15, delay: .zero,
                       options: [.curveEaseInOut, .allowUserInteraction, .preferredFramesPerSecond60],
                       animations: { self.view.layoutIfNeeded() },
                       completion: nil)
    }
    
    private func calculateCurrentValue(contentOffsetY: CGFloat) -> CGFloat {
        tableViewContainerTopConstraint.constant - contentOffsetY
    }
    
    private func calculateMaxValue() -> CGFloat {
        detailsStackView.frame.height - tableViewTopMinConstant
    }
}

