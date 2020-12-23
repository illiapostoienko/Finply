//
//  TitleInputCellViewModel.swift
//  Finply
//
//  Created by Illia Postoienko on 28.11.2020.
//

import RxSwift
import RxCocoa

protocol TitleInputCellViewModelType {
    
    var inputText: AnyObserver<String> { get }
    
    // Output
    var nameString: Observable<String> { get }
}

final class TitleInputCellViewModel: TitleInputCellViewModelType {
    
    var inputText: AnyObserver<String> { currentName.asObserver() }
    
    var nameString: Observable<String> { currentName }
    
    private let currentName = BehaviorSubject<String>(value: "")
}
