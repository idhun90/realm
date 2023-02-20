//
//  Satisfaction.swift
//  realm
//
//  Created by 도헌 on 2023/02/19.
//

import Foundation
import RealmSwift

final class Satisfaction: Object, Identifiable {
    @Persisted var id: String = UUID().uuidString
    @Persisted var name: String
    @Persisted var createdDate: Date = Date.now
    
    convenience init(name: String) {
        self.init()
        self.name = name
    }
}

extension Results where Element == Satisfaction {
    func getSatisfactionIndex(withID id: Satisfaction.ID) -> Self.Index {
        guard let index = self.firstIndex(where: { $0.id == id } ) else { fatalError("no have maching Satisfaction") }
        return index
    }
    
    func getSatisfaction(withID id: Satisfaction.ID) -> Satisfaction {
        let index = self.getSatisfactionIndex(withID: id)
        return self[index]
    }
    
    func getSatisfaction(withName name: String) -> Satisfaction {
        guard let satisfaction = self.first(where: { $0.name == name } ) else {
            guard let defaultSatisfaction = self.first(where: { $0.name == "Fit" } ) else { fatalError("no have maching Satisfaction")}
            return defaultSatisfaction
        }
        return satisfaction
    }
    
    func getSatisfactionID(withName name: String) -> Satisfaction.ID {
        return self.getSatisfaction(withName: name).id
    }
}

