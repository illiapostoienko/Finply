//
//  RealmStorage.swift
//  Finply
//
//  Created by Illia Postoienko on 02.10.2020.
//

import RealmSwift
import Realm
import RxSwift

protocol RealmStorageType {
    associatedtype RealmModelType: Object
    
    func getAll() -> Single<[RealmModelType]>
    func getAllSortedBy(key: String, ascending: Bool) -> Single<[RealmModelType]>
    func get(by predicate: NSPredicate) -> Single<[RealmModelType]>
    func getByPrimaryKey(id: String) -> Single<RealmModelType?>
    
    func add(objects: [RealmModelType]) -> Single<Void>
    func update(objects: [RealmModelType]) -> Single<Void>
    func delete(objects: [RealmModelType]) -> Single<Void>
    func deleteByPrimaryKey(id: String) -> Single<Void>
    func deleteAll() -> Single<Void>
    func deleteAllObjects() -> Single<Void>
}

extension RealmStorageType {
    
    func getAll() -> Single<[RealmModelType]> {
        return Single.create { observer in
            do {
                let realm = try Realm()
                let objects = realm.objects(RealmModelType.self)
                observer(.success(Array(objects)))
            } catch {
                observer(.error(error))
            }
            
            return Disposables.create()
        }
    }
    
    func getAllSortedBy(key: String, ascending: Bool) -> Single<[RealmModelType]> {
        return Single.create { observer in
            do {
                let realm = try Realm()
                let objects = realm.objects(RealmModelType.self).sorted(byKeyPath: key, ascending: ascending)
                observer(.success(Array(objects)))
            } catch {
                observer(.error(error))
            }

            return Disposables.create()
        }
    }
    
    func get(by predicate: NSPredicate) -> Single<[RealmModelType]> {
        return Single.create { observer in
            do {
                let realm = try Realm()
                let objects = realm.objects(RealmModelType.self).filter(predicate)
                observer(.success(Array(objects)))
            } catch {
                observer(.error(error))
            }
            
            return Disposables.create()
        }
    }
    
    func getByPrimaryKey(id: String) -> Single<RealmModelType?> {
        return Single.create { observer in
            do {
                let realm = try Realm()
                let object = realm.object(ofType: RealmModelType.self, forPrimaryKey: id)
                observer(.success(object))
            } catch {
                observer(.error(error))
            }
            
            return Disposables.create()
        }
    }
    
    func add(objects: [RealmModelType]) -> Single<Void> {
        return update(objects: objects)
    }
    
    func update(objects: [RealmModelType]) -> Single<Void> {
        return Single.create { observer in
            do {
                let realm = try Realm()
                try realm.write {
                    realm.add(objects, update: .modified)
                }
                observer(.success(()))
            } catch {
                observer(.error(error))
            }
            
            return Disposables.create()
        }
    }
    
    func delete(objects: [RealmModelType]) -> Single<Void> {
        return Single.create { observer in
            do {
                let realm = try Realm()
                try realm.write {
                    realm.delete(objects)
                }
                observer(.success(()))
            } catch {
                observer(.error(error))
            }
            
            return Disposables.create()
        }
    }
    
    func deleteByPrimaryKey(id: String) -> Single<Void> {
        return Single.create { observer in
            do {
                let realm = try Realm()
                let object = realm.object(ofType: RealmModelType.self, forPrimaryKey: id)
                try realm.write {
                    object.flatMap{ realm.delete($0) }
                }
                observer(.success(()))
            } catch {
                observer(.error(error))
            }
            
            return Disposables.create()
        }
    }
    
    func deleteAll() -> Single<Void> {
        return Single.create { observer in
            do {
                let realm = try Realm()
                let objects = realm.objects(RealmModelType.self)
                realm.delete(objects)
                observer(.success(()))
            } catch {
                observer(.error(error))
            }
            
            return Disposables.create()
        }
    }
    
    func deleteAllObjects() -> Single<Void> {
        return Single.create { observer in
            do {
                let realm = try Realm()
                try realm.write {
                    realm.deleteAll()
                }
                observer(.success(()))
            } catch {
                observer(.error(error))
            }
            
            return Disposables.create()
        }
    }
}
