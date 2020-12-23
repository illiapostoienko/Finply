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
    @IBOutlet private var selectorArrowView: UIView!
    @IBOutlet private var selectorButton: UIButton!
    @IBOutlet private var tableView: UITableView!
    
    var viewModel: AddEditAccountViewModelType!
    
    private var dataSource: RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, AddEditAccountTableViewItem>>!
    
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    func bindViewModel() {
        viewModel.output.sceneState
            .subscribe(onNext: { [weak self] state in
                self?.selectorArrowView.isHidden = !state.isAddAction
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
    }
    
    @IBAction func selectorButtonPressed(_ sender: Any) {
        let options = AddEditAccountSceneState.addOptions
        
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        AddEditAccountSceneState.addOptions.forEach{ option in
            let action = UIAlertAction(title: option.title, style: .default) { [weak self] _ in
                self?.viewModel.setup(with: option)
            }
            sheet.addAction(action)
        }
        
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(sheet, animated: true, completion: nil)
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
}
