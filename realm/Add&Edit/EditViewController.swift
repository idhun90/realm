//
//  EditViewController.swift
//  realm
//
//  Created by 도헌 on 2023/02/15.
//

import UIKit

import RealmSwift

final class EditViewController: UIViewController {
    
    enum Section: Int, Hashable {
        case name
        case list
        case fitAndSatisfaction
        case size
        case price
        case orderDate
        case urlAndNote
    }
    
    enum Row: Hashable {
        case editName(String)
        case editCategory(String)
        case editBrand(String)
        case editSize(String)
        case editColor(String)
        case editFit(String)
        case editSatisfaction(String)
        case editPrice(String)
        case editOrderDate(Date)
        case editUrl(String)
        case editNote(String)
        
        var text: String {
            switch self {
            case .editName(_): return "Name"
            case .editCategory(_): return "Category"
            case .editBrand(_): return "Brand"
            case .editSize(_): return "Size"
            case .editColor(_): return "Color"
            case .editFit(_): return "Fit"
            case .editSatisfaction(_): return "Satisfaction"
            case .editPrice(_): return "Price"
            case .editOrderDate(_): return "OrderDate"
            case .editUrl(_): return "URL"
            case .editNote(_): return "Note"
            }
        }
    }
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Row>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Row>
    
    private var collectionView: UICollectionView!
    private var dataSource: DataSource!
    private var snapshot: Snapshot!

    private let database = RealmManager.shared
    
    var item: Item
    var editingItem: Item
    var isAddMode: Bool
    
    var itemChangeHandler: ((Item) -> Void) = { _ in }

    private var isItemChanged = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationItem()
        configureCollectionView()
        configureDataSource()
        applySnapshot()
        modalInPresentationToggle()
    }
    
    init(item: Item, isAdd: Bool) {
        self.item = item
        self.editingItem = Item(name: item.name, category: item.category, brand: item.brand, size: item.size, fit: item.fit, satisfaction: item.satisfaction, color: item.color, price: item.price, orderDate: item.orderDate, url: item.url, note: item.note)
        self.isAddMode = isAdd
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func modalInPresentationToggle() {
        isModalInPresentation = isItemChanged ? true : false
    }

    private func configureNavigationItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(tappedDoneButton))
    }
    
    @objc private func tappedDoneButton() {

        if isAddMode {
            itemChangeHandler(editingItem)
            dismiss(animated: true)
        } else {
            if !isValueChanged(old: item, new: editingItem) {
                dismiss(animated: true)
                
            } else {
                itemChangeHandler(editingItem)
                dismiss(animated: true)
            }
        }
    }
    
    private func isValueChanged(old: Item, new: Item) -> Bool {
        if old.name != new.name || old.category != new.category || old.brand != new.brand ||
        old.size != new.size || old.fit != new.fit || old.satisfaction != new.satisfaction ||
        old.color != new.color || old.price != new.price || old.orderDate != new.orderDate ||
            old.url != new.url || old.note != new.note {
            return true
        } else {
            return false
        }
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.delegate = self
        collectionView.keyboardDismissMode = .onDrag
        view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.0),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0)
        ])
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let listConfiguration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        return UICollectionViewCompositionalLayout.list(using: listConfiguration)
    }
    
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Row>(handler: cellRegistrationHandler)
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        })
    }
    
    func applySnapshot() {
        snapshot = Snapshot()
        snapshot.appendSections([.name, .list, .fitAndSatisfaction, .size, .price, .orderDate, .urlAndNote])
        snapshot.appendItems([.editName(editingItem.name)], toSection: .name)
        snapshot.appendItems([.editCategory(editingItem.category), .editBrand(editingItem.brand), .editColor(editingItem.color)], toSection: .list)
        snapshot.appendItems([.editFit(editingItem.fit), .editSatisfaction(editingItem.satisfaction)], toSection: .fitAndSatisfaction)
        snapshot.appendItems([.editSize(editingItem.size)], toSection: .size)
        snapshot.appendItems([.editPrice(editingItem.price)], toSection: .price)
        snapshot.appendItems([.editOrderDate(editingItem.orderDate)], toSection: .orderDate)
        snapshot.appendItems([.editUrl(editingItem.url), .editNote(editingItem.note)], toSection: .urlAndNote)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

}

extension EditViewController {
    private func cellRegistrationHandler(cell: UICollectionViewListCell, indexPath: IndexPath, row: Row) {
        guard let section = Section(rawValue: indexPath.section) else { return }
        switch (section, row) {
        case (.name, .editName(let name)):
            cell.contentConfiguration = textFieldConfiguration(for: cell, with: name, placeholder: Row.editName("").text, row: .editName(""))
        case (.list, .editCategory(let category)):
            cell.contentConfiguration = editListConfiguration(for: cell, with: category, at: .editCategory(""))
            cell.accessories = [.disclosureIndicator(displayed: .always)]
        case (.list, .editBrand(let brand)):
            cell.contentConfiguration = editListConfiguration(for: cell, with: brand, at: .editBrand(""))
            cell.accessories = [.disclosureIndicator(displayed: .always)]
        case (.list, .editColor(let color)):
            cell.contentConfiguration = editListConfiguration(for: cell, with: color, at: .editColor(""))
            cell.accessories = [.disclosureIndicator(displayed: .always)]
        case (.fitAndSatisfaction, .editFit(let fit)):
            cell.contentConfiguration = editListConfiguration(for: cell, with: fit, at: .editFit(""))
            cell.accessories = [.disclosureIndicator(displayed: .always)]
        case (.fitAndSatisfaction, .editSatisfaction(let satisfaction)):
            cell.contentConfiguration = editListConfiguration(for: cell, with: satisfaction, at: .editSatisfaction(""))
            cell.accessories = [.disclosureIndicator(displayed: .always)]
        case (.size, .editSize(let size)):
            cell.contentConfiguration = editListConfiguration(for: cell, with: size, at: .editSize(""))
            cell.accessories = [.disclosureIndicator(displayed: .always)]
        case (.price, .editPrice(let price)):
                cell.contentConfiguration = textFieldConfiguration(for: cell, with: price, placeholder: Row.editPrice("").text, row: .editPrice(""))
        case (.orderDate, .editOrderDate(let date)):
            cell.contentConfiguration = datePickerConfiguration(for: cell, with: date)
        case (.urlAndNote, .editUrl(let url)):
            cell.contentConfiguration = textFieldConfiguration(for: cell, with: url, placeholder: Row.editUrl("").text, row: .editUrl(""))
        case (.urlAndNote, .editNote(let note)):
            cell.contentConfiguration = textViewConfiguration(for: cell, with: note)
        default:
            fatalError("error (section, row)")
        }
    }
}
 
//MARK: - UICollectionViewDelegate
extension EditViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let row = dataSource.itemIdentifier(for: indexPath) else { return false }
        
        switch row {
        case .editCategory(_):
            let vc = SelectCategoryViewController(item: editingItem)
            vc.onchangeCategory = { [weak self] category in
                guard let self = self else { return }
                self.editingItem.category = category
                self.applySnapshot()
                
                //❌ Thread 1: "Attempted to reconfigure item identifier that does not exist in the snapshot: realm.EditViewController.Row.editCategory(\"Bottom\")"
                //var newSnapshot = self.dataSource.snapshot()
                //newSnapshot.reconfigureItems([.editCategory(self.editingItem.category)])
                //self.dataSource.apply(newSnapshot, animatingDifferences: false)
                print("EditView - Category changed")
            }
            navigationController?.pushViewController(vc, animated: true)
            return false
        case .editBrand(_):
            let vc = SelectBrandViewController(item: editingItem)
            vc.onchangeBrand = { [weak self] brand in
                self?.editingItem.brand = brand
                self?.applySnapshot()
                print("EditView - Brand changed")
            }
            navigationController?.pushViewController(vc, animated: true)
            return false
        case .editColor(_):
            let vc = SelectColorViewController(item: editingItem)
            vc.onchangeColor = { [weak self] color in
                self?.editingItem.color = color
                self?.applySnapshot()
                print("EditView - Color changed")
            }
            navigationController?.pushViewController(vc, animated: true)
            return false
        case .editFit(_):
            let vc = SelectFitViewController(item: editingItem)
            vc.onchangeFit = { [weak self] fit in
                self?.editingItem.fit = fit
                self?.applySnapshot()
                print("EditView - Fit changed")
            }
            navigationController?.pushViewController(vc, animated: true)
            return false
        case .editSatisfaction(_):
            let vc = SelectSatisfactionViewController(item: editingItem)
            vc.onchangeSatisfaction = { [weak self] satisfaction in
                self?.editingItem.satisfaction = satisfaction
                self?.applySnapshot()
                print("EditView - Satisfaction changed")
            }
            navigationController?.pushViewController(vc, animated: true)
            return false
        case .editSize(_):
            let vc = SelectSizeViewController(item: editingItem)
            vc.onchangeSize = { [weak self] size in
                self?.editingItem.size = size
                self?.applySnapshot()
                print("EditView - Size changed")
            }
            navigationController?.pushViewController(vc, animated: true)
            return false
        default: return false
        }
    }
}
