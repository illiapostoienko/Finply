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
    var accounts: [AccountDto]
    // color, icon, iconset
    
    let accountGroupModel: AccountGroupModel
    
    init(accountGroupModel: AccountGroupModel) {
        self.accountGroupModel = accountGroupModel
        
        self.id = accountGroupModel.id
        self.name = accountGroupModel.name
        self.order = accountGroupModel.order
        self.accounts = accountGroupModel.accounts.map{ AccountDto(accountModel: $0) }
    }
    
    func applyDbUpdates() {
        accountGroupModel.name = name
        accountGroupModel.order = order
        
        accountGroupModel.accounts.removeAll()
        accountGroupModel.accounts.append(objectsIn: accounts.map{ $0.accountModel })
    }
    
    mutating func updateOrder(to order: Int) {
        self.order = order
    }
    
    static func == (lhs: AccountGroupDto, rhs: AccountGroupDto) -> Bool {
        return lhs.id == rhs.id
            && lhs.name == rhs.name
            && lhs.order == rhs.order
            && lhs.accounts == rhs.accounts
    }
}
