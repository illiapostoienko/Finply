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
    @IBOutlet private var tableViewBackgroundView: UIView!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var addOperationButton: UIButton!
    
    @IBOutlet private var tableViewContainerTopConstraint: NSLayoutConstraint!
    @IBOutlet private var tableViewBackgroundViewTopConstraint: NSLayoutConstraint!
    
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

        let height = tableViewBackgroundView.frame.height
        let width = tableViewBackgroundView.frame.width

        tableViewBackgroundView.layer.shadowPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: width, height: 20)).cgPath
        tableViewBackgroundView.layer.shadowRadius = 5
        tableViewBackgroundView.layer.shadowOpacity = 0.1
        tableViewBackgroundView.layer.shadowColor = #colorLiteral(red: 0.4588235294, green: 0.4705882353, blue: 0.5450980392, alpha: 1).cgColor
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
        
        tableView.rx.itemSelected.subscribe(onNext: { indexPath in
            print("itemselected: \(indexPath)")
        }).disposed(by: bag)
    }
}

// MARK: - Table View
extension AccountDetailsViewController: UITableViewDelegate {
    
    private func setupTableView() {
        tableView.dataSource = nil
        //tableView.delegate = nil // needed due to internal logic of RxDatasources
        tableView.delegate = self
        
        tableView.register(cellType: AccountOperationCell.self)
        tableView.register(headerFooterViewType: AccountOperationsSectionHeader.self)
        
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderHeight = 32
        tableView.tableFooterView = UIView()
        
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
        })
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView() as AccountOperationsSectionHeader
        guard let section = viewModel.currentOperationSections.value[safe: section] else { return nil }
        headerView.setupDate(sectionDateFormatter.string(from: section.date))
        return headerView
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
