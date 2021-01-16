//
//  AccountHeaderViewModel.swift
//  Finply
//
//  Created by Illia Postoienko on 06.11.2020.
//

import RxSwift
import RxCocoa

protocol AccountHeaderViewModelType {
    // Inputs
    var profileTap: PublishSubject<Void> { get }
    var accountTap: PublishSubject<Void> { get }
    var editAccountTap: PublishSubject<Void> { get }
    
    // Outputs
    var ballanceDriver: Driver<String> { get }
}

final class AccountHeaderViewModel: AccountHeaderViewModelType {
    
    // Inputs
    let profileTap = PublishSubject<Void>()
    let accountTap = PublishSubject<Void>()
    let editAccountTap = PublishSubject<Void>()
    
    // Outputs
    var ballanceDriver: Driver<String>
    
    private let currentBallance = BehaviorSubject<Double>(value: 0.0)
    
    init() {
        ballanceDriver = currentBallance.asDriver(onErrorJustReturn: 0.0).map{ "\($0)" }
    }
}
