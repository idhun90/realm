//
//  Size.swift
//  realm
//
//  Created by 도헌 on 2023/02/19.
//

import Foundation
import RealmSwift

final class Size: Object, Identifiable {
    @Persisted var id: String = UUID().uuidString
    @Persisted var name: String
    @Persisted var createdDate: Date = Date.now
    
    convenience init(name: String) {
        self.init()
        self.name = name
    }
}

extension Results where Element == Size {
    func getSizeIndex(withID id: Size.ID) -> Self.Index {
        guard let index = self.firstIndex(where: { $0.id == id } ) else { fatalError("no have maching size") }
        return index
    }
    
    func getSize(withID id: Size.ID) -> Size {
        let index = self.getSizeIndex(withID: id)
        return self[index]
    }
    
    func getSize(withName name: String) -> Size {
        guard let size = self.first(where: { $0.name == name } ) else {
            guard let defaultSize = self.first(where: { $0.name == "None" } ) else { fatalError("no have maching size")}
            return defaultSize
        }
        return size
    }
    
    func getSizeID(withName name: String) -> Size.ID {
        return self.getSize(withName: name).id
    }
}

