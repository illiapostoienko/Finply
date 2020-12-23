//
//  BallanceInputCellViewModel.swift
//  Finply
//
//  Created by Illia Postoienko on 21.12.2020.
//

import RxSwift

protocol BallanceInputCellViewModelType {
    var currencyTapped: PublishSubject<Void> { get }
}

final class BallanceInputCellViewModel: BallanceInputCellViewModelType {
    
    let currencyTapped = PublishSubject<Void>()
    
}
