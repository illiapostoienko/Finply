//
//  AccountGroupDto.swift
//  Finply
//
//  Created by Illia Postoienko on 24.12.2020.
//

struct AccountGroupDto: OrderableType, Equatable {
    
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
    
    mutating func updateOrder(to order: Int) {
        self.order = order
    }
    
    static func == (lhs: AccountGroupDto, rhs: AccountGroupDto) -> Bool {
        return lhs.id == rhs.id
            && lhs.name == rhs.name
            && lhs.order == rhs.order
    }
}
