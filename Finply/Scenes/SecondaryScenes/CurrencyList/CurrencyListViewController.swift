//  
//  CurrencyListViewController.swift
//  Finply
//
//  Created by Illia Postoienko on 21.12.2020.
//

import UIKit
import RxSwift
import RxCocoa
import RxSwiftExt

final class CurrencyListViewController: UIViewController {
    
    @IBOutlet private var closeButton: UIButton!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var searchTextField: UITextField!
    @IBOutlet private var tableView: UITableView!
    
    private var dataSource: UITableViewDiffableDataSource<Section, Item>!
    
    private let popularCurrencies: [Currency] = [.dollar, .euro, .poundSterling]
    private var allCurrencies: [Currency] { Currency.allCases }
    private var selectedCurrency: Currency?
    
    private var popularAndSelectedCurrencies: [Currency] {
        var popularAndSelected = popularCurrencies
        selectedCurrency.map{
            guard !popularAndSelected.contains($0) else { return }
            popularAndSelected.append($0)
        }
        return popularAndSelected
    }
    
    private var otherCurrencies: [Currency] {
        return allCurrencies.filter{ !popularAndSelectedCurrencies.contains($0) }
    }
    
    private lazy var completeInitialItemsSet: [Item] = {
        [.separator(text: "Popular")]
        + popularAndSelectedCurrencies.map{ .currency(cellModel: CurrencyCellModel(currency: $0)) }
        + [.separator(text: "Alphabetical")]
        + otherCurrencies.map{ .currency(cellModel: CurrencyCellModel(currency: $0)) }
    }()
    
    private var currentlyShownItems: [Item] = []
    
    // Coordination
    var completeCoordinationResult: Observable<CurrencyListCoordinationResult> { _completeCoordinationResult }
    private let _completeCoordinationResult = PublishSubject<CurrencyListCoordinationResult>()
    private let bag = DisposeBag()
    
    private let throttler = Throttler(scheduledDelay: 0.5)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        setupTableView()
        
        closeButton.rx.tap
            .map{ .close }
            .bind(to: _completeCoordinationResult)
            .disposed(by: bag)
        
        tableView.rx.itemSelected
            .map{ [unowned self] indexPath in self.currentlyShownItems[safe: indexPath.row] }
            .unwrap()
            .map{
                if case .currency(let currencyModel) = $0 {
                    return currencyModel.currency
                } else { return nil }
            }
            .unwrap()
            .map{ .selectedCurrency($0) }
            .bind(to: _completeCoordinationResult)
            .disposed(by: bag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        performQuery(with: nil, forceUpdate: true)
    }
    
    func setSelected(currency: Currency) {
        selectedCurrency = currency
    }
    
    private func setupTableView() {
        tableView.register(cellType: CurrencyListCell.self)
        tableView.register(cellType: CurrencyListSeparatorCell.self)
        
        tableView.tableFooterView = UIView()
        
        dataSource = UITableViewDiffableDataSource<Section, Item>(tableView: tableView) { [unowned self] tableView, indexPath, item -> UITableViewCell? in
            switch item {
            case .currency(let currencyModel):
                let cell = tableView.dequeueReusableCell(for: indexPath) as CurrencyListCell
                cell.setCurrency(currencyModel.currency)
                if self.selectedCurrency == currencyModel.currency { cell.setSelected(true) }
                return cell
                
            case .separator(let text):
                let cell = tableView.dequeueReusableCell(for: indexPath) as CurrencyListSeparatorCell
                cell.set(text: text)
                return cell
            }
        }
        
        dataSource?.defaultRowAnimation = .fade
    }
    
    private func performQuery(with keyword: String?, forceUpdate: Bool = false) {
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        
        guard let keyword = keyword, !keyword.isEmpty else {
            snapshot.appendSections([.all])
            snapshot.appendItems(completeInitialItemsSet, toSection: .all)
            
            self.currentlyShownItems = completeInitialItemsSet
            
            dataSource.apply(snapshot, animatingDifferences: !forceUpdate)
            throttler.throttle {}
            
            return
        }
        
        throttler.throttle { [weak self] in
            guard let self = self else { return }
            
            let filtered = self.completeInitialItemsSet.filter{
                let lowercasedKeyword = keyword.lowercased()
                if case .currency(let currencyModel) = $0 {
                    return currencyModel.currency.localized.lowercased().contains(lowercasedKeyword)
                        || currencyModel.currency.rawValue.lowercased().contains(lowercasedKeyword)
                } else { return false }
            }
            
            self.currentlyShownItems = filtered
            
            snapshot.appendSections([.all])
            snapshot.appendItems([.separator(text: "Search Results:")])
            snapshot.appendItems(filtered, toSection: .all)
            
            self.dataSource.apply(snapshot, animatingDifferences: !forceUpdate)
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        performQuery(with: textField.text)
    }
    
    enum Section {
        case all
    }
    
    private enum Item: Hashable {
        case currency(cellModel: CurrencyCellModel)
        case separator(text: String)
    }
    
    private struct CurrencyCellModel: Hashable {
        let currency: Currency
        let id = UUID()
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        static func == (lhs: CurrencyCellModel, rhs: CurrencyCellModel) -> Bool {
            return lhs.id == rhs.id
        }
        
        func contains(_ keyword: String) -> Bool {
            let lowercasedKeyword = keyword.lowercased()
            return currency.localized.lowercased().contains(lowercasedKeyword)
                || currency.rawValue.lowercased().contains(lowercasedKeyword)
        }
    }
}

extension CurrencyListViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
