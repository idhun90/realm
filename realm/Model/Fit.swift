//
//  Fit.swift
//  realm
//
//  Created by 도헌 on 2023/02/19.
//

import Foundation
import RealmSwift

final class Fit: Object, Identifiable {
    @Persisted var id: String = UUID().uuidString
    @Persisted var name: String
    @Persisted var createdDate: Date = Date.now
    
    convenience init(name: String) {
        self.init()
        self.name = name
    }
}

extension Results where Element == Fit {
    func getFitIndex(withID id: Fit.ID) -> Self.Index {
        guard let index = self.firstIndex(where: { $0.id == id } ) else { fatalError("no have maching fit") }
        return index
    }
    
    func getFit(withID id: Fit.ID) -> Fit {
        let index = self.getFitIndex(withID: id)
        return self[index]
    }
    
    func getFit(withName name: String) -> Fit {
        guard let fit = self.first(where: { $0.name == name } ) else {
            guard let defaultFit = self.first(where: { $0.name == "Regular" } ) else { fatalError("no have maching fit")}
            return defaultFit
        }
        return fit
    }
    
    func getFitID(withName name: String) -> Fit.ID {
        return self.getFit(withName: name).id
    }
}
