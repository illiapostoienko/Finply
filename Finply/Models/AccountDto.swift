//
//  AccountDto.swift
//  Finply
//
//  Created by Illia Postoienko on 24.12.2020.
//

final class AccountDto: OrderableType {
    
    let id: String
    var name: String
    var baseValueInCents: Int
    var calculatedValueInCents: Int
    var currency: Currency
    var order: Int
    
    //color, icon, colorSet
    
    let accountModel: AccountModel
    
    init(accountModel: AccountModel) {
        self.accountModel = accountModel
        
        id = accountModel.id
        name = accountModel.name
        baseValueInCents = accountModel.baseValueInCents
        calculatedValueInCents = accountModel.calculatedValueInCents
        currency = accountModel.currency
        order = accountModel.order
    }
    
    func applyDbUpdates() {
        accountModel.name = name
        accountModel.baseValueInCents = baseValueInCents
        accountModel.calculatedValueInCents = calculatedValueInCents
        accountModel.currency = currency
        accountModel.order = order
    }
    
    func updateOrder(to order: Int) {
        self.order = order
    }
}
