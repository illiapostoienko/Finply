//
//  Rx+Extensions.swift
//  Finply
//
//  Created by Illia Postoienko on 09.11.2020.
//

import RxSwift
import RxCocoa

func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }

    return returnValue
}
