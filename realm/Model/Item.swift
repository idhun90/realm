//
//  Item.swift
//  realm
//
//  Created by 도헌 on 2023/02/14.
//

import Foundation
import RealmSwift

final class Item: Object, Identifiable {
    @Persisted var id: String = UUID().uuidString
    @Persisted var name: String
    @Persisted var category: String
    @Persisted var brand: String
    @Persisted var size: String
    @Persisted var fit: String
    @Persisted var satisfaction: String
    @Persisted var color: String
    @Persisted var price: String
    @Persisted var orderDate: Date
    @Persisted var url: String
    @Persisted var note: String
    
    convenience init(name: String, category: String = "Outer", brand: String = "None", size: String = "Free", fit: String = "Regular", satisfaction: String = "Fit", color: String = "None", price: String = "", orderDate: Date = Date.now, url: String = "", note: String = "") {
        self.init()
        self.name = name
        self.category = category
        self.brand = brand
        self.size = size
        self.fit = fit
        self.satisfaction = satisfaction
        self.color = color
        self.price = price
        self.orderDate = orderDate
        self.url = url
        self.note = note
    }
}


extension Results where Element == Item {
    func indexOfItem(with id: Item.ID) -> Self.Index {
        guard let index = firstIndex(where: { $0.id == id }) else {
            fatalError("no have machting id")
        }
        return index
    }
}
