//
//  RealmObjectDelegate.swift
//  Finply
//
//  Created by Illia Postoienko on 12.12.2020.
//

import Foundation
import RealmSwift

protocol RealmObjectDelegate: class {
    associatedtype Model: Object
    
    func update(model: Model)
    func delete(model: Model)
}

private class _AnyRealmObjectDelegate<Model: Object>: RealmObjectDelegate {
    
    func update(model: Model) {
        fatalError("This method is abstract")
    }
    
    func delete(model: Model) {
        fatalError("This method is abstract")
    }
}

private class _RealmObjectDelegate<Base: RealmObjectDelegate>: _AnyRealmObjectDelegate<Base.Model> {
    private let _base: Base
    
    init(_ base: Base) {
        _base = base
    }
    
    override func update(model: Model) {
        _base.update(model: model)
    }
    
    override func delete(model: Model) {
        _base.delete(model: model)
    }
}

class AnyRealmObjectDelegate<Model: Object>: RealmObjectDelegate {
    
    private let _delegate: _AnyRealmObjectDelegate<Model>
    
    init<DelegateType: RealmObjectDelegate>(_ delegate: DelegateType) where DelegateType.Model == Model {
        _delegate = _RealmObjectDelegate(delegate)
    }
    
    func update(model: Model) {
        _delegate.update(model: model)
    }
    
    func delete(model: Model) {
        _delegate.delete(model: model)
    }
}
