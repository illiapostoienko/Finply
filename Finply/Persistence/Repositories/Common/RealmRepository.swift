//
//  RealmRepository.swift
//  Finply
//
//  Created by Illia Postoienko on 12.12.2020.
//

import Foundation
import RealmSwift

//swiftlint:disable force_try
class RealmRepository<Model: Object> {
    
    deinit {
        print("deinit RealmRepository \(Model.self)")
    }
    
    let realm: Realm
    
    init() {
        realm = try! Realm()
    }
    
    func getAll() -> Results<Model> {
        realm.objects(Model.self)
    }
    
    func getAllSorted(orderKey: String, ascending: Bool) -> Results<Model> {
        realm.objects(Model.self).sorted(byKeyPath: orderKey, ascending: ascending)
    }
    
    func get(by predicate: NSPredicate) -> Results<Model> {
        realm.objects(Model.self).filter(predicate)
    }
    
    func getByPrimaryKey(id: String) -> Model? {
        realm.object(ofType: Model.self, forPrimaryKey: id)
    }
    
    func addOrUpdate(models: [Model]) {
        try! realm.write {
            realm.add(models, update: .modified)
        }
    }
    
    func delete(models: [Model]) {
        try! realm.write {
            realm.delete(models)
        }
    }

    func deleteAll() {
        let objects = realm.objects(Model.self)
        realm.delete(objects)
    }
}
