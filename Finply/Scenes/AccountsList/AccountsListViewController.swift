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
import SwipeCellKit

final class AccountsListViewController: UIViewController, BindableType {
    
    @IBOutlet private var backButton: UIButton!
    @IBOutlet private var plusButton: UIButton!
    
    @IBOutlet private var listTypeLabel: UILabel!
    @IBOutlet private var selectionArrowImageView: UIImageView!
    @IBOutlet private var listTypeSelectionButton: UIButton!
    
    @IBOutlet private var shadowContainer: UIView!
    @IBOutlet private var tabsContainerTopConstraint: NSLayoutConstraint!
    @IBOutlet private var accountsTabButton: UIButton!
    @IBOutlet private var accountGroupsTabButton: UIButton!
    
    @IBOutlet private var tableView: UITableView!
    
    private var dataSource: RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, AccountsListTableItem>>!
    
    var viewModel: AccountsListViewModelType!
    
    private var listSelectionState: ListSelectionState = .collapsed {
        didSet {
            tabsContainerTopConstraint.constant = listSelectionState.tabsContainerTopConstant
            shadowContainer.isUserInteractionEnabled = listSelectionState.shadowContainerIsUserInteractionEnabled
            
            UIView.animate(withDuration: 0.3) { [unowned self] in
                self.shadowContainer.alpha = self.listSelectionState.shadowContainerAlpha
                self.selectionArrowImageView.image = self.listSelectionState.arrowImage
                self.view.layoutIfNeeded()
            }
        }
    }
    
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.shadowContainerTapped(_:)))
        shadowContainer.addGestureRecognizer(tap)
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
        
        viewModel.output.tabSelected
            .map{
                switch $0 {
                case .accounts: return "Accounts"
                case .groups: return "Account Groups"
                }
            }
            .bind(to: listTypeLabel.rx.text)
            .disposed(by: bag)
        
        backButton.rx.tap
            .bind(to: viewModel.input.backButtonTap)
            .disposed(by: bag)
        
        plusButton.rx.tap
            .bind(to: viewModel.input.addButtonTap)
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
        
        self.rx.methodInvoked(#selector(viewDidAppear(_:)))
            .ignoreContent()
            .bind(to: viewModel.input.reload)
            .disposed(by: bag)
        
        accountsTabButton.rx.tap
            .do(onNext: {[unowned self] in self.listSelectionState = .collapsed })
            .map{ _ in .accounts }
            .bind(to: viewModel.input.tabButtonTap)
            .disposed(by: bag)
        
        accountGroupsTabButton.rx.tap
            .do(onNext: {[unowned self] in self.listSelectionState = .collapsed })
            .map{ _ in .groups }
            .bind(to: viewModel.input.tabButtonTap)
            .disposed(by: bag)
    }
    
    @IBAction func listTypeSelectionPressed(_ sender: UIButton) {
        listSelectionState.toggle()
    }
    
    @objc private func shadowContainerTapped(_ sender: UITapGestureRecognizer? = nil) {
        listSelectionState = .collapsed
    }
    
    private func setupTableView() {
        tableView.register(cellType: AccountsListAccountCell.self)
        tableView.register(cellType: AccountsListGroupCell.self)
        
        dataSource = RxTableViewSectionedAnimatedDataSource(animationConfiguration: AnimationConfiguration(insertAnimation: .fade, reloadAnimation: .fade, deleteAnimation: .fade),
            configureCell: { [unowned self] dataSource, tableView, indexPath, _ in
                if let spacer = tableView.reorder.spacerCell(for: indexPath) { return spacer }
                switch dataSource[indexPath] {
                case .account(let viewModel):
                    var cell = tableView.dequeueReusableCell(for: indexPath) as AccountsListAccountCell
                    cell.bind(to: viewModel)
                    cell.delegate = self
                    return cell
                case .accountGroup(let viewModel):
                    var cell = tableView.dequeueReusableCell(for: indexPath) as AccountsListGroupCell
                    cell.bind(to: viewModel)
                    cell.delegate = self
                    return cell
                }
            }, canEditRowAtIndexPath: { _, _  in true }
        )
        
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        
        tableView.reorder.delegate = self
        tableView.reorder.cellScale = 1.05
        tableView.reorder.shadowOpacity = 0
        tableView.reorder.shadowRadius = 0
    }
    
    private func setPlaceholder(_ state: Bool) {
        // set placeholder for background of tableView
    }
    
    enum ListSelectionState {
        case collapsed
        case expanded
        
        mutating func toggle() {
            switch self {
            case .collapsed: self = .expanded
            case .expanded: self = .collapsed
            }
        }
        
        var tabsContainerTopConstant: CGFloat {
            switch self {
            case .collapsed: return -102
            case .expanded: return 0
            }
        }
        
        var shadowContainerAlpha: CGFloat {
            switch self {
            case .collapsed: return 0
            case .expanded: return 0.5
            }
        }
        
        var shadowContainerIsUserInteractionEnabled: Bool {
            switch self {
            case .collapsed: return false
            case .expanded: return true
            }
        }
        
        var arrowImage: UIImage? {
            switch self {
            case .collapsed: return UIImage(named: "arrow-down")
            case .expanded: return UIImage(named: "arrow-up")
            }
        }
    }
}

extension AccountsListViewController: TableViewReorderDelegate {
    func tableViewDidFinishReordering(_ tableView: UITableView, from initialSourceIndexPath: IndexPath, to finalDestinationIndexPath: IndexPath) {
        viewModel.input.changeOrder
            .onNext((fromIndex: initialSourceIndexPath.row, toIndex: finalDestinationIndexPath.row))
        tableView.reloadData()
    }
}

extension AccountsListViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: nil) { [unowned self] _, indexPath in
            let alert = UIAlertController(title: "Delete Account", message: "Are you sure to delete account? This action cannot be recovered.", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let delete = UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                self.viewModel.input.rowDeleteTap.onNext(indexPath.row)
            })
            alert.addAction(cancel)
            alert.addAction(delete)
            
            self.present(alert, animated: true, completion: nil)
        }
        
        deleteAction.image = UIImage(named: "swipe_delete")
        deleteAction.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.0)
        deleteAction.transitionDelegate = ScaleTransition.default
        deleteAction.hidesWhenSelected = true
        
        let editAction = SwipeAction(style: .default, title: nil) { [unowned self] _, indexPath in
            self.viewModel.input.rowEditTap.onNext(indexPath.row)
        }
        
        editAction.image = UIImage(named: "swipe_edit")
        editAction.hidesWhenSelected = true
        editAction.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.0)
        editAction.transitionDelegate = ScaleTransition.default
        
        return [deleteAction, editAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .none
        options.transitionStyle = .drag
        options.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.0)
        return options
    }
}
