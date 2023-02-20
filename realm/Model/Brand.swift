//
//  Brand.swift
//  realm
//
//  Created by 도헌 on 2023/02/19.
//

import Foundation
import RealmSwift

final class Brand: Object, Identifiable {
    @Persisted var id: String = UUID().uuidString
    @Persisted var name: String
    @Persisted var createdDate: Date = Date.now
    
    convenience init(name: String) {
        self.init()
        self.name = name
    }
}

extension Results where Element == Brand {
    func getBrandIndex(withID id: Brand.ID) -> Self.Index {
        guard let index = self.firstIndex(where: { $0.id == id } ) else { fatalError("no have maching brand") }
        return index
    }
    
    func getBrand(withID id: Brand.ID) -> Brand {
        let index = self.getBrandIndex(withID: id)
        return self[index]
    }
    
    func getBrand(withName name: String) -> Brand {
        guard let brand = self.first(where: { $0.name == name } ) else {
            guard let defaultBrand = self.first(where: { $0.name == "None" } ) else { fatalError("no have maching brand")}
            return defaultBrand
        }
        return brand
    }
    
    func getBrandID(withName name: String) -> Brand.ID {
        return self.getBrand(withName: name).id
    }
}
