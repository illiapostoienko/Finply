//
//  ColorSelectionCellViewModel.swift
//  Finply
//
//  Created by Illia Postoienko on 21.12.2020.
//

import RxSwift
import RxCocoa

protocol ColorSelectionCellViewModelType {
    var colorSetsListResult: AnyObserver<ColorSetsListCoordinationResult> { get }
}

final class ColorSelectionCellViewModel: ColorSelectionCellViewModelType {
    
    var colorSetsListResult: AnyObserver<ColorSetsListCoordinationResult> { _colorSetsListResult.asObserver() }
    private let _colorSetsListResult = PublishSubject<ColorSetsListCoordinationResult>()
}
