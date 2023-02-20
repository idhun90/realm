//
//  RealmManager.swift
//  realm
//
//  Created by 도헌 on 2023/02/15.
//

import Foundation

import RealmSwift

final class RealmManager {
    
    private init() { }
    
    static let shared = RealmManager()
    private let realm = try! Realm()
    
    public func getRealmURL() -> URL {
        return realm.configuration.fileURL!
    }
    
    public func getAllDatas<T: Object>(_ object: T.Type, keyPath: String, ascending: Bool = false) -> Results<T> {
        return realm.objects(object).sorted(byKeyPath: keyPath, ascending: ascending)
    }
    
    public func add<T: Object>(_ object: T, completion: (() -> Void)? = nil) {
        do {
            try realm.write {
                realm.add(object)
                print("Add Success")
                completion?()
            }
        } catch let error {
            print(error)
        }
    }
    
    public func delete<T: Object>(_ object: T, completion: (() -> Void)? = nil) {
        do {
            try realm.write {
                realm.delete(object)
                print("Delete Success")
                completion?()
            }
        } catch let error {
            print(error)
        }
    }
    
    //MARK: - Item update
    public func update(old: Item, new: Item, completion: (() -> Void)? = nil) {
        do {
            try realm.write {
                old.name = new.name
                old.category = new.category
                old.brand = new.brand
                old.size = new.size
                old.fit = new.fit
                old.satisfaction = new.satisfaction
                old.color = new.color
                old.price = new.price
                old.orderDate = new.orderDate
                old.url = new.url
                old.note = new.note
                print("item Updated")
                completion?()
            }
        } catch let error {
            print(error)
        }
    }

}
