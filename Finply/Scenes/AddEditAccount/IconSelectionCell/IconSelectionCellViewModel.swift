//
//  IconSelectionCellViewModel.swift
//  Finply
//
//  Created by Illia Postoienko on 21.12.2020.
//

import Foundation
import RxSwift
import RxCocoa

protocol IconSelectionCellViewModelType {
    var iconsListResult: AnyObserver<IconsListCoordinationResult> { get }
}

final class IconSelectionCellViewModel: IconSelectionCellViewModelType {
    
    var iconsListResult: AnyObserver<IconsListCoordinationResult> { _iconsListResult.asObserver() }
    private let _iconsListResult = PublishSubject<IconsListCoordinationResult>()
}
