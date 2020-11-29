//
//  BaseModalViewController.swift
//  Finply
//
//  Created by Illia Postoienko on 28.11.2020.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class BaseModalViewController: UIViewController, BindableType {
    
    @IBOutlet private var closeButton: UIButton!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var checkButton: UIButton!
    @IBOutlet private  var tableView: UITableView!
    
    var viewModel: BaseModalViewModelType!
    
    private var dataSource: RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, BaseModalTableViewItem>>!
    
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    func bindViewModel() {
        checkButton.isHidden = viewModel.output.isCheckButtonHidden
                
        viewModel.output.title
            .drive(titleLabel.rx.text)
            .disposed(by: bag)
        
        closeButton.rx.tap
            .bind(to: viewModel.input.closeButtonTap)
            .disposed(by: bag)
        
        checkButton.rx.tap
            .bind(to: viewModel.input.checkButtonTap)
            .disposed(by: bag)
        
        tableView.rx.itemSelected
            .map{ $0.row }
            .bind(to: viewModel.input.itemSelected)
            .disposed(by: bag)
        
        viewModel.output.dataSource
            .map{ [AnimatableSectionModel(model: "", items: $0)] }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
    }
    
    func setupTableView() {
        tableView.register(cellType: TitleInputCell.self)
        
        dataSource = RxTableViewSectionedAnimatedDataSource(
            configureCell: { dataSource, tableView, indexPath, _ in
                switch dataSource[indexPath] {
                case .titleInput(let viewModel):
                    var cell = tableView.dequeueReusableCell(for: indexPath) as TitleInputCell
                    cell.bind(to: viewModel)
                    return cell
                case .ballanceInput: fatalError()
                case .currencySelect: fatalError()
                case .iconSelect: fatalError()
                case .colorSelect: fatalError()
                case .accountsSelect: fatalError()
                }
            }
        )
        
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
    }
}
