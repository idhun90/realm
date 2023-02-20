//
//  DetailViewController + CellConfiguration.swift
//  realm
//
//  Created by 도헌 on 2023/02/19.
//

import UIKit

extension DetailViewController {
    func listConfiguration(for cell: UICollectionViewListCell, at row: Row) -> UIListContentConfiguration {
        var contentConfiguration = cell.defaultContentConfiguration()
        contentConfiguration.text = text(for: row)
        contentConfiguration.textProperties.font = UIFont.preferredFont(forTextStyle: row.textStyle)
        contentConfiguration.image = row.image
        return contentConfiguration
    }

    func text(for row: Row) -> String {
        switch row {
        case .name: return editingItem.name
        case .category: return editingItem.category
        case .brand: return editingItem.brand
        case .size: return editingItem.size
        case .fit: return editingItem.fit
        case .satisfaction: return editingItem.satisfaction
        case .color: return editingItem.color
        case .price: return editingItem.price.isEmpty ? "-" : editingItem.price
        case .orderDate: return editingItem.orderDate.formatted(date: .numeric, time: .omitted)
        case .url: return editingItem.url.isEmpty ? "-" : editingItem.url
        case .note: return editingItem.note.isEmpty ? "-" : editingItem.note
        }
    }

}

