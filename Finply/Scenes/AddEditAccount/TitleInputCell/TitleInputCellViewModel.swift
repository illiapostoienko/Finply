//
//  TitleInputCellViewModel.swift
//  Finply
//
//  Created by Illia Postoienko on 28.11.2020.
//

import RxSwift
import RxCocoa

protocol TitleInputCellViewModelType {
    
    // BiBinded to Cell
    var currentName: BehaviorRelay<String> { get }
    
    func setCurrentName(_ name: String)
}

final class TitleInputCellViewModel: TitleInputCellViewModelType {
    
    // BiBinded to Cell
    let currentName = BehaviorRelay<String>(value: "")
    
    func setCurrentName(_ name: String) {
        currentName.accept(name)
    }
}
