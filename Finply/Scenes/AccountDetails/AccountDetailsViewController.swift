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

protocol AccountDetailsViewControllerDelegate: class {
    func tableViewStateChanged(to state: AccountDetailsViewController.TableState)
}

final class AccountDetailsViewController: UIViewController {
    
    @IBOutlet private var detailsStackView: UIStackView!
    @IBOutlet private var accountHeaderView: AccountHeaderView!
    @IBOutlet private var monthDetailsView: AccountMonthDetailsView!
    @IBOutlet private var tableViewBackgroundView: UIView!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var addOperationButton: UIButton!
    @IBOutlet private var clearSeparatorView: UIView!
    @IBOutlet private var tableViewTopConstraint: NSLayoutConstraint!
    
    weak var delegate: AccountDetailsViewControllerDelegate?
    
    var viewModel: AccountDetailsViewModelType!
    
    private var dataSource: RxTableViewSectionedAnimatedDataSource<AccountOperationsTableSection>!
    private let bag = DisposeBag()
    
    private var tableViewState: TableState = .collapsed {
        didSet {
            if !tableViewState.isBetween { previousTableViewState = tableViewState }
            delegate?.tableViewStateChanged(to: tableViewState)
        }
    }
    private var previousTableViewState: TableState = .collapsed
    private var shouldStopDecelerating: Bool = false
    private var isEndDraggingUpdatesInProgress: Bool = false
    private var expandedStateMaxValue: CGFloat { clearSeparatorView.frame.height + detailsStackView.frame.height - 92 }
        
    lazy var sectionDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .full
        return dateFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupShadows()
    }
    
    private func setupShadows() {
        let rect = CGRect(x: tableViewBackgroundView.bounds.minX,
                          y: tableViewBackgroundView.bounds.minY,
                          width: tableViewBackgroundView.bounds.width,
                          height: tableViewBackgroundView.bounds.height + expandedStateMaxValue + 52)
        tableViewBackgroundView.layer.shadowPath = UIBezierPath(rect: rect).cgPath
        tableViewBackgroundView.layer.shadowOffset = .zero
        tableViewBackgroundView.layer.shadowRadius = 5
        tableViewBackgroundView.layer.shadowOpacity = 0.1
        tableViewBackgroundView.layer.shadowColor = #colorLiteral(red: 0.4588235294, green: 0.4705882353, blue: 0.5450980392, alpha: 1).cgColor
        tableViewBackgroundView.layer.shouldRasterize = true
        tableViewBackgroundView.layer.rasterizationScale = UIScreen.main.scale
    }
}

// MARK: - Bindings
extension AccountDetailsViewController: BindableType {
    
    func bindViewModel() {
        accountHeaderView.bind(to: viewModel.accountHeaderViewModel)
        monthDetailsView.bind(to: viewModel.accountMonthDetailsViewModel)
        
        viewModel.output.dataSource
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        
        addOperationButton.rx.tap
            .bind(to: viewModel.input.addButtonTap)
            .disposed(by: bag)
        
        tableView.rx.itemSelected
            .do(onNext: { [weak self] in self?.tableView.deselectRow(at: $0, animated: true) })
            .bind(to: viewModel.input.rowSelected).disposed(by: bag)
    }
}

// MARK: - Table View
extension AccountDetailsViewController: UITableViewDelegate {
    
    private func setupTableView() {
        tableView.dataSource = nil
        tableView.delegate = self
        
        tableView.register(cellType: AccountOperationCell.self)
        tableView.register(headerFooterViewType: AccountOperationsSectionHeader.self)
        
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        tableView.showsVerticalScrollIndicator = false
        
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
        guard let section = viewModel.output.currentOperationSections.value[safe: section] else { return nil }
        headerView.setupDate(sectionDateFormatter.string(from: section.date))
      
        return headerView
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !isEndDraggingUpdatesInProgress else { return }
        
        // disable scroll down in collapsed state
        if tableViewState.isCollapsed, scrollView.contentOffset.y <= 0 {
            scrollView.contentOffset = .zero
        }
        
        let currentValue = tableViewTopConstraint.constant - scrollView.contentOffset.y
        
        guard currentValue < 0 else {
            if tableViewTopConstraint.constant != 0 { tableViewTopConstraint.constant = 0 }
            tableViewState = .collapsed
            return
        }
        
        guard currentValue > -expandedStateMaxValue, !scrollView.isDecelerating else {
            if tableViewTopConstraint.constant != -expandedStateMaxValue { tableViewTopConstraint.constant = -expandedStateMaxValue }
            tableViewState = .expanded
            return
        }
        
        let percent = abs(currentValue / expandedStateMaxValue)
        
        tableViewState = .between(percent: percent)
        
        tableViewTopConstraint.constant = currentValue
        tableView.contentOffset = .zero
        
        adjustOtherViewsLayout(by: percent)
        UIApplication.shared.setStatusBarHidden(percent > 0.7, with: UIStatusBarAnimation.fade)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard tableViewState.isBetween else { return }
        let currentValue = tableViewTopConstraint.constant - scrollView.contentOffset.y
        let percent = abs(currentValue / expandedStateMaxValue)
        guard (0...1) ~= percent else { return }
        
        isEndDraggingUpdatesInProgress = true
        let shouldExpand: Bool
        
        if decelerate {
            let isScrollingDown = scrollView.panGestureRecognizer.translation(in: scrollView.superview).y > 0
            shouldExpand = !isScrollingDown
            shouldStopDecelerating = true
        } else {
            let isScrollingDown = scrollView.panGestureRecognizer.translation(in: scrollView.superview).y > 0
            if isScrollingDown, previousTableViewState.isExpanded {
                shouldExpand = (0.9...1) ~= percent
            } else {
                shouldExpand = (0.5...1) ~= percent
            }
        }
        
        tableViewState = shouldExpand ? .expanded : .collapsed
        tableViewTopConstraint.constant = shouldExpand ? -expandedStateMaxValue : 0
        
        UIView.animate(withDuration: 0.15, delay: .zero,
                       options: [.curveEaseInOut, .allowUserInteraction, .preferredFramesPerSecond60],
                       animations: { [weak self] in
                            self?.adjustOtherViewsLayout(by: shouldExpand ? 1 : 0)
                            self?.view.layoutIfNeeded()
                       },
                       completion: { [weak self] _ in
                            self?.isEndDraggingUpdatesInProgress = false
                       })
        
        UIApplication.shared.setStatusBarHidden(shouldExpand, with: .fade)
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if tableViewState.isExpanded, shouldStopDecelerating {
            scrollView.setContentOffset(.zero, animated: true)
            shouldStopDecelerating = false
        }
    }
    
    private func adjustOtherViewsLayout(by percent: CGFloat) {
        accountHeaderView.adjustLayout(by: percent)
    }
    
    enum TableState {
        case expanded
        case collapsed
        case between(percent: CGFloat)
        
        var isExpanded: Bool {
            if case .expanded = self { return true }
            return false
        }
        
        var isCollapsed: Bool {
            if case .collapsed = self { return true }
            return false
        }
        
        var isBetween: Bool {
            if case .between = self { return true }
            return false
        }
        
        var betweenValue: CGFloat? {
            if case .between(let value) = self { return value }
            return nil
        }
    }
}
