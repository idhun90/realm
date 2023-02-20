//
//  Category.swift
//  realm
//
//  Created by 도헌 on 2023/02/19.
//

import Foundation
import RealmSwift

final class Category: Object, Identifiable {
    @Persisted var id: String = UUID().uuidString
    @Persisted var name: String
    @Persisted var createdDate: Date = Date.now
    
    convenience init(name: String) {
        self.init()
        self.name = name
    }
}

extension Results where Element == Category {
    func getCategoryIndex(withID id: Category.ID) -> Self.Index {
        guard let index = self.firstIndex(where: { $0.id == id } ) else { fatalError("no have maching category") }
        return index
    }
    
    func getCategory(withID id: Category.ID) -> Category {
        let index = self.getCategoryIndex(withID: id)
        return self[index]
    }
    
    func getCategory(withName name: String) -> Category {
        guard let category = self.first(where: { $0.name == name } ) else {
            guard let defaultCategory = self.first(where: { $0.name == "Outer" } ) else { fatalError("no have maching category")}
            return defaultCategory
        }
        return category
    }
    
    func getCategoryID(withName name: String) -> Category.ID {
        return self.getCategory(withName: name).id
    }
}

