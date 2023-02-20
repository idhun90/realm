//
//  Color.swift
//  realm
//
//  Created by 도헌 on 2023/02/19.
//

import Foundation
import RealmSwift

final class Color: Object, Identifiable {
    @Persisted var id: String = UUID().uuidString
    @Persisted var name: String
    @Persisted var createdDate: Date = Date.now
    
    convenience init(name: String) {
        self.init()
        self.name = name
    }
}

extension Results where Element == Color {
    func getColorIndex(withID id: Color.ID) -> Self.Index {
        guard let index = self.firstIndex(where: { $0.id == id } ) else { fatalError("no have maching color") }
        return index
    }
    
    func getColor(withID id: Color.ID) -> Color {
        let index = self.getColorIndex(withID: id)
        return self[index]
    }
    
    func getColor(withName name: String) -> Color {
        guard let color = self.first(where: { $0.name == name } ) else {
            guard let defaultColor = self.first(where: { $0.name == "None" } ) else { fatalError("no have maching color")}
            return defaultColor
        }
        return color
    }
    
    func getColorID(withName name: String) -> Color.ID {
        return self.getColor(withName: name).id
    }
}
