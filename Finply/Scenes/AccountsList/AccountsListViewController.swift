//
//  AccountsListViewController.swift
//  Finply
//
//  Created by Illia Postoienko on 23.10.2020.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class AccountsListViewController: UIViewController, BindableType {
    
    @IBOutlet private var backButton: UIButton!
    @IBOutlet private var accountsLabel: UILabel!
    @IBOutlet private var plusButton: UIButton!
    
    @IBOutlet private var accountsTabButton: UIButton!
    @IBOutlet private var groupsTabButton: UIButton!
    @IBOutlet private var tabButtonsStack: UIStackView!
    @IBOutlet private var tabButtonsStackLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private var sliderLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private var sliderTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet private var tableView: UITableView!
    
    private var dataSource: RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, AccountsListTableItem>>!
    
    var viewModel: AccountsListViewModelType!
    
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        updateTabAppearance(by: .accounts)
    }
    
    func bindViewModel() {
        
        viewModel.output.dataSource
            .map{ [AnimatableSectionModel(model: "", items: $0)] }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        
        viewModel.output.dataSource
            .map{ $0.isEmpty }
            .subscribe(onNext: { [weak self] state in
                self?.setPlaceholder(state)
            })
            .disposed(by: bag)
        
        backButton.rx.tap
            .bind(to: viewModel.input.backButtonTap)
            .disposed(by: bag)
        
        plusButton.rx.tap
            .do(onNext: { [weak self] in
                self?.tableView.setEditing(false, animated: true)
            })
            .bind(to: viewModel.input.addButtonTap)
            .disposed(by: bag)
        
        Observable.merge(accountsTabButton.rx.tap.map{ .accounts },
                         groupsTabButton.rx.tap.map{ .groups })
            .do(onNext: { [weak self] tab in
                self?.updateTabAppearance(by: tab)
                self?.tableView.setEditing(false, animated: true)
            })
            .bind(to: viewModel.input.tabButtonTap)
            .disposed(by: bag)

        tableView.rx.itemSelected
            .map{ $0.row }
            .bind(to: viewModel.input.rowSelected)
            .disposed(by: bag)
        
        tableView.rx
            .itemMoved
            .map{ (fromIndex: $0.row, toIndex: $1.row) }
            .bind(to: viewModel.input.changeOrder)
            .disposed(by: bag)
    }
    
    private func setupTableView() {
        tableView.register(cellType: AccountsListAccountCell.self)
        tableView.register(cellType: AccountsListGroupCell.self)
        
        dataSource = RxTableViewSectionedAnimatedDataSource(
            configureCell: { dataSource, tableView, indexPath, _ in
                if let spacer = tableView.reorder.spacerCell(for: indexPath) { return spacer }
                switch dataSource[indexPath] {
                case .account(let viewModel):
                    var cell = tableView.dequeueReusableCell(for: indexPath) as AccountsListAccountCell
                    cell.bind(to: viewModel)
                    cell.swipeDelegate = self
                    return cell
                case .group(let viewModel):
                    var cell = tableView.dequeueReusableCell(for: indexPath) as AccountsListGroupCell
                    cell.bind(to: viewModel)
                    cell.swipeDelegate = self
                    return cell
                }
            }
        )
        
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        
        tableView.reorder.delegate = self
        tableView.reorder.cellScale = 1.05
        tableView.reorder.shadowOpacity = 0
        tableView.reorder.shadowRadius = 0
    }
    
    private func updateTabAppearance(by tab: AccountsListTab) {
        let buttonToOperate: UIButton
        
        switch tab {
        case .accounts: buttonToOperate = accountsTabButton
        case .groups: buttonToOperate = groupsTabButton
        }
        
        //Slider
        let width = view.frame.width
        let buttonFrame = buttonToOperate.frame
        let labelFrame = buttonToOperate.titleLabel?.frame
        
        let leftValue = tabButtonsStackLeadingConstraint.constant + buttonFrame.minX
        let rightValue = width - buttonFrame.maxX - tabButtonsStackLeadingConstraint.constant
        
        buttonToOperate.titleLabel.map{
            leftValue + $0.frame.minX
            rightValue + ($0.frame.maxX - $0.frame.width - $0.frame.minX)
        }
        
        sliderLeadingConstraint.constant = leftValue
        sliderTrailingConstraint.constant = rightValue
        
        self.view.layoutIfNeeded()
        
        //Button Color
        switch tab {
        case .accounts:
            accountsTabButton.setTitleColor(#colorLiteral(red: 0.3019607843, green: 0.4, blue: 0.8745098039, alpha: 1), for: [])
            groupsTabButton.setTitleColor(#colorLiteral(red: 0.6823529412, green: 0.7176470588, blue: 0.7568627451, alpha: 1), for: [])
        case .groups:
            accountsTabButton.setTitleColor(#colorLiteral(red: 0.6823529412, green: 0.7176470588, blue: 0.7568627451, alpha: 1), for: [])
            groupsTabButton.setTitleColor(#colorLiteral(red: 0.3019607843, green: 0.4, blue: 0.8745098039, alpha: 1), for: [])
        }
    }
    
    private func setPlaceholder(_ state: Bool) {
        // set placeholder for background of tableView
    }
}

extension AccountsListViewController: TableViewReorderDelegate {
    func tableViewDidFinishReordering(_ tableView: UITableView, from initialSourceIndexPath: IndexPath, to finalDestinationIndexPath: IndexPath) {
        viewModel.input.changeOrder
            .onNext((fromIndex: initialSourceIndexPath.row, toIndex: finalDestinationIndexPath.row))
    }
}

extension AccountsListViewController: SwipeableCellDelegate {
    func didStartSwiping(_ cell: SwipeableCell) {
        tableView.visibleCells.forEach{ visibleCell in
            guard visibleCell !== cell else { return }
            if let accountCell = visibleCell as? AccountsListAccountCell { accountCell.resetCellPosition(toInitial: true) }
            if let groupCell = visibleCell as? AccountsListGroupCell { groupCell.resetCellPosition(toInitial: true) }
        }
    }
}
