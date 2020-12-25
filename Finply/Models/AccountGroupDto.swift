//
//  AccountGroupDto.swift
//  Finply
//
//  Created by Illia Postoienko on 24.12.2020.
//

final class AccountGroupDto: OrderableType {
    
    let id: String
    var name: String
    var order: Int
    
    // color, icon, iconset
    
    let accountGroupModel: AccountGroupModel
    
    init(accountGroupModel: AccountGroupModel) {
        self.accountGroupModel = accountGroupModel
        
        self.id = accountGroupModel.id
        self.name = accountGroupModel.name
        self.order = accountGroupModel.order
    }
    
    func applyDbUpdates() {
        accountGroupModel.name = name
        accountGroupModel.order = order
    }
    
    func updateOrder(to order: Int) {
        self.order = order
    }
}
