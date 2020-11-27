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
    @IBOutlet private var editButton: UIButton!
    
    @IBOutlet private var allTabButton: UIButton!
    @IBOutlet private var accountsTabButton: UIButton!
    @IBOutlet private var groupsTabButton: UIButton!
    @IBOutlet private var tabButtonsStack: UIStackView!
    @IBOutlet private var tabButtonsStackLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private var sliderLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private var sliderTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var plusButton: UIButton!
    
    private var dataSource: RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, AccountsListTableItem>>!
    
    var viewModel: AccountsListViewModelType!
    var transitionFrame: CGRect = .zero
    
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    func bindViewModel() {
        
        viewModel.dataSource
            .map{ [AnimatableSectionModel(model: "", items: $0)] }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        
        Observable.combineLatest(viewModel.dataSource.map{ $0.isEmpty }.asObservable(),
                                 viewModel.currentTab.asObservable())
        // placeholder
        
        viewModel.currentTab
            .drive(onNext: { [weak self] tab in
                self?.updateSlider(by: tab)
            })
            .disposed(by: bag)
        
        viewModel.isEditModeEnabled
            .drive(onNext: { [weak self] isEditModeEnabled in
                self?.tableView.isEditing = isEditModeEnabled
                // change picture of edit button for edit mode?
            })
            .disposed(by: bag)
        
        backButton.rx.tap
            .bind(to: viewModel.backButtonTap)
            .disposed(by: bag)
        
        editButton.rx.tap
            .bind(to: viewModel.editButtonTap)
            .disposed(by: bag)
        
        plusButton.rx.tap
            .bind(to: viewModel.addButtonTap)
            .disposed(by: bag)
        
        Observable.merge(allTabButton.rx.tap.map{ .all },
                         accountsTabButton.rx.tap.map{ .accounts },
                         groupsTabButton.rx.tap.map{ .groups } )
            .bind(to: viewModel.tabButtonTap)
            .disposed(by: bag)

        tableView.rx.itemSelected
            .map{ $0.row }
            .bind(to: viewModel.rowSelected)
            .disposed(by: bag)
        
        tableView.rx
            .itemDeleted
            .map{ $0.row }
            .bind(to: viewModel.deleteRowIntent)
            .disposed(by: bag)
        
        tableView.rx
            .itemMoved
            .map{ (fromIndex: $0.row, toIndex: $1.row) }
            .bind(to: viewModel.changeOrderIntent)
            .disposed(by: bag)
    }
    
    private func setupTableView() {
        tableView.dataSource = nil
        tableView.register(cellType: AccountsListAccountCell.self)
        tableView.register(cellType: AccountsListGroupCell.self)
        
        dataSource = RxTableViewSectionedAnimatedDataSource(
            configureCell: { dataSource, tableView, indexPath, _ in
                switch dataSource[indexPath] {
                case .account(let viewModel):
                    var cell = tableView.dequeueReusableCell(for: indexPath) as AccountsListAccountCell
                    cell.bind(to: viewModel)
                    return cell
                case .group(let viewModel):
                    var cell = tableView.dequeueReusableCell(for: indexPath) as AccountsListGroupCell
                    cell.bind(to: viewModel)
                    return cell
                }
            },
            canEditRowAtIndexPath: { _, _ in
                return true
            },
            canMoveRowAtIndexPath: { _, _ in
                return true
            }
        )
        
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
    }
    
    private func updateSlider(by tab: AccountsListTab) {
        let buttonToOperate: UIButton
        
        switch tab {
        case .all: buttonToOperate = allTabButton
        case .accounts: buttonToOperate = accountsTabButton
        case .groups: buttonToOperate = groupsTabButton
        }
        
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
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
}
