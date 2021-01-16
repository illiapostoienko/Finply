//
//  AddEditAccountViewController.swift
//  Finply
//
//  Created by Illia Postoienko on 21.12.2020.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class AddEditAccountViewController: UIViewController, BindableType {
    
    @IBOutlet private var closeButton: UIButton!
    @IBOutlet private var checkButton: UIButton!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var selectorArrowBaseView: UIView!
    @IBOutlet private var selectorArrowImageView: UIImageView!
    @IBOutlet private var selectorButton: UIButton!
    @IBOutlet private var tableView: UITableView!
    
    @IBOutlet private var shadowView: UIView!
    @IBOutlet private var addAccountTabButton: UIButton!
    @IBOutlet private var addAccountGroupTabButton: UIButton!
    @IBOutlet private var actionsContainerTopConstraint: NSLayoutConstraint!
    
    var viewModel: AddEditAccountViewModelType!
    
    private var dataSource: RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, AddEditAccountTableViewItem>>!
    
    private var actionSelectionState: ActionActionSelectionState = .collapsed {
        didSet {
            self.view.layoutIfNeeded()
            actionsContainerTopConstraint.constant = actionSelectionState.actionsContainerTopConstant
            shadowView.isUserInteractionEnabled = actionSelectionState.shadowViewIsUserInteractionEnabled
            
            UIView.animate(withDuration: 0.3) { [unowned self] in
                self.shadowView.alpha = self.actionSelectionState.shadowViewAlpha
                self.selectorArrowImageView.image = self.actionSelectionState.arrowImage
                self.view.layoutIfNeeded()
            }
        }
    }
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.shadowContainerTapped(_:)))
        shadowView.addGestureRecognizer(tap)
    }
    
    func bindViewModel() {
        viewModel.output.sceneState
            .subscribe(onNext: { [weak self] state in
                self?.selectorArrowBaseView.isHidden = !state.isAddAction
                self?.selectorButton.isEnabled = state.isAddAction
                self?.titleLabel.text = state.title
            })
        
        closeButton.rx.tap
            .bind(to: viewModel.input.closeButtonTap)
            .disposed(by: bag)
        
        checkButton.rx.tap
            .bind(to: viewModel.input.checkButtonTap)
            .disposed(by: bag)
        
        viewModel.output.dataSource
            .map{ [AnimatableSectionModel(model: "", items: $0)] }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        
        tableView.rx.itemSelected
            .do(onNext: { [weak self] in self?.tableView.deselectRow(at: $0, animated: true) })
            .map{ $0.row }
            .bind(to: viewModel.input.rowSelected).disposed(by: bag)
        
        viewModel.output.isCheckButtonEnabled
            .bind(to: checkButton.rx.isEnabled)
            .disposed(by: bag)
    }
    
    @IBAction private func selectorButtonPressed(_ sender: Any) {
        actionSelectionState.toggle()
    }
    
    @objc private func shadowContainerTapped(_ sender: UITapGestureRecognizer? = nil) {
        actionSelectionState = .collapsed
    }
    
    @IBAction private func addAccountButtonPressed(_ sender: Any) {
        viewModel.setup(with: .addAccount)
        actionSelectionState = .collapsed
    }
    
    @IBAction private func addAccountGroupButtonPressed(_ sender: Any) {
        viewModel.setup(with: .addAccountGroup)
        actionSelectionState = .collapsed
    }
    
    func setupTableView() {
        tableView.register(cellType: TitleInputCell.self)
        tableView.register(cellType: BallanceInputCell.self)
        tableView.register(cellType: IconSelectionCell.self)
        tableView.register(cellType: ColorSelectionCell.self)
        tableView.register(cellType: AccountsSelectionCell.self)
        tableView.register(cellType: ClearCell.self)
        
        dataSource = RxTableViewSectionedAnimatedDataSource(animationConfiguration: .init(insertAnimation: .fade, reloadAnimation: .fade, deleteAnimation: .fade),
            configureCell: { dataSource, tableView, indexPath, _ in
                switch dataSource[indexPath] {
                case .titleInput(let viewModel):
                    var cell = tableView.dequeueReusableCell(for: indexPath) as TitleInputCell
                    cell.bind(to: viewModel)
                    return cell
                    
                case .ballanceInput(let viewModel):
                    var cell = tableView.dequeueReusableCell(for: indexPath) as BallanceInputCell
                    cell.bind(to: viewModel)
                    return cell
                    
                case .iconSelect(let viewModel):
                    var cell = tableView.dequeueReusableCell(for: indexPath) as IconSelectionCell
                    cell.bind(to: viewModel)
                    return cell
                    
                case .colorSelect(let viewModel):
                    var cell = tableView.dequeueReusableCell(for: indexPath) as ColorSelectionCell
                    cell.bind(to: viewModel)
                    return cell
                    
                case .accountsSelect(let viewModel):
                    var cell = tableView.dequeueReusableCell(for: indexPath) as AccountsSelectionCell
                    cell.bind(to: viewModel)
                    return cell
                
                case .clear:
                    return tableView.dequeueReusableCell(for: indexPath) as ClearCell
                }
            }
        )
        
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
    }
    
    enum ActionActionSelectionState {
        case collapsed
        case expanded
        
        mutating func toggle() {
            switch self {
            case .collapsed: self = .expanded
            case .expanded: self = .collapsed
            }
        }
        
        var actionsContainerTopConstant: CGFloat {
            switch self {
            case .collapsed: return -103
            case .expanded: return 0
            }
        }
        
        var shadowViewAlpha: CGFloat {
            switch self {
            case .collapsed: return 0
            case .expanded: return 0.5
            }
        }
        
        var shadowViewIsUserInteractionEnabled: Bool {
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
