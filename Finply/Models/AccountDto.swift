//
//  AccountDto.swift
//  Finply
//
//  Created by Illia Postoienko on 24.12.2020.
//

struct AccountDto: OrderableType, Equatable {
    
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
    
    mutating func updateOrder(to order: Int) {
        self.order = order
    }
    
    static func == (lhs: AccountDto, rhs: AccountDto) -> Bool {
        return lhs.id == rhs.id
            && lhs.name == rhs.name
            && lhs.baseValueInCents == rhs.baseValueInCents
            && lhs.calculatedValueInCents == rhs.calculatedValueInCents
            && lhs.currency == rhs.currency
            && lhs.order == rhs.order
    }
}
