//
//  DomainEntityConvertible.swift
//  Finply
//
//  Created by Illia Postoienko on 02.10.2020.
//

import Foundation

protocol DomainEntityConvertibleType {
    associatedtype DomainEntityType

    func toDomain() -> DomainEntityType
}
