//  
//  CurrencyListViewController.swift
//  Finply
//
//  Created by Illia Postoienko on 21.12.2020.
//

import UIKit
import RxSwift
import RxCocoa

final class CurrencyListViewController: UIViewController {
    
    @IBOutlet private var closeButton: UIButton!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var searchTextField: UITextField!
    @IBOutlet private var tableView: UITableView!
    
    private var dataSource: UITableViewDiffableDataSource<Section, CurrencyCellModel>!
    
    private let popularCurrencies: [Currency] = [.dollar, .euro, .poundSterling]
    private var allCurrencies: [Currency] { Currency.allCases }
    private var popularAndSelectedCurrencies: [Currency] {
        var popularAndSelected = popularCurrencies
        selectedCurrency.map{ popularAndSelected.append($0) }
        return popularAndSelected
    }
    private var otherCurrencies: [Currency] {
        return allCurrencies.filter{ !popularAndSelectedCurrencies.contains($0) }
    }
    
    private var selectedCurrency: Currency?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        performQuery(with: nil)
    }
    
    func setSelected(currency: Currency) {
        selectedCurrency = currency
    }
    
    private func setupTableView() {
        tableView.register(cellType: CurrencyListCell.self)
        tableView.register(headerFooterViewType: CurrencyListSectionHeader.self)
        
        tableView.delegate = self
        
        dataSource = UITableViewDiffableDataSource<Section, CurrencyCellModel>(tableView: tableView) { [unowned self] tableView, indexPath, currencyCellModel -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(for: indexPath) as CurrencyListCell
            cell.setCurrency(currencyCellModel.currency)
            if self.selectedCurrency == currencyCellModel.currency { cell.setSelected(true) }
            return cell
        }
    }
    
    private func performQuery(with keyword: String?) {
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, CurrencyCellModel>()
        
        guard let keyword = keyword, !keyword.isEmpty else {
            snapshot.appendSections([.popular])
            snapshot.appendItems(popularCurrencies.map{ CurrencyCellModel(currency: $0) },
                                 toSection: .popular)
            
            snapshot.appendSections([.alphabet])
            snapshot.appendItems(otherCurrencies.map{ CurrencyCellModel(currency: $0) },
                                 toSection: .alphabet)
            
            dataSource.apply(snapshot, animatingDifferences: true)
            return
        }
        
        let filtered = allCurrencies
            .map{ CurrencyCellModel(currency: $0) }
            .filter{ $0.contains(keyword) }
        
        snapshot.appendItems(filtered)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        performQuery(with: textField.text)
    }
    
    private enum Section: Int {
        case popular
        case alphabet
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

extension CurrencyListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView() as CurrencyListSectionHeader
        
        guard let section = Section(rawValue: section) else { return nil }
        
        // number of section and raw value could be different
        headerView.setupText("\(section)")
        
        return headerView
    }
}
