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
        updateSlider(by: .accounts)
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
        
        viewModel.output.isEditModeEnabled
            .drive(onNext: { [weak self] isEditModeEnabled in
                self?.tableView.setEditing(isEditModeEnabled, animated: true)
                // change picture of edit button for edit mode?
            })
            .disposed(by: bag)
        
        backButton.rx.tap
            .bind(to: viewModel.input.backButtonTap)
            .disposed(by: bag)
        
        editButton.rx.tap
            .bind(to: viewModel.input.editButtonTap)
            .disposed(by: bag)
        
        plusButton.rx.tap
            .bind(to: viewModel.input.addButtonTap)
            .disposed(by: bag)
        
        Observable.merge(accountsTabButton.rx.tap.map{ .accounts },
                         groupsTabButton.rx.tap.map{ .groups })
            .do(onNext: { [weak self] tab in
                self?.updateSlider(by: tab)
            })
            .bind(to: viewModel.input.tabButtonTap)
            .disposed(by: bag)

        tableView.rx.itemSelected
            .map{ $0.row }
            .bind(to: viewModel.input.rowSelected)
            .disposed(by: bag)
        
        tableView.rx
            .itemDeleted
            .map{ $0.row }
            .bind(to: viewModel.input.deleteRowIntent)
            .disposed(by: bag)
        
        tableView.rx
            .itemMoved
            .map{ (fromIndex: $0.row, toIndex: $1.row) }
            .bind(to: viewModel.input.changeOrderIntent)
            .disposed(by: bag)
    }
    
    private func setupTableView() {
        //tableView.dataSource = nil
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
        tableView.allowsSelectionDuringEditing = true
    }
    
    private func updateSlider(by tab: AccountsListTab) {
        let buttonToOperate: UIButton
        
        switch tab {
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
    
    private func setPlaceholder(_ state: Bool) {
        // set placeholder for background of tableView
    }
}
