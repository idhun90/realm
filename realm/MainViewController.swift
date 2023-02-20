//
//  Main.swift
//  realm
//
//  Created by 도헌 on 2023/02/15.
//

import UIKit

import RealmSwift

final class MainViewController: UIViewController {
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Int, Item.ID>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Item.ID>
    
    private var collectionView: UICollectionView!
    private var datasource: DataSource!
    private var snapshot: Snapshot!
    
    private let database = RealmManager.shared
    
    var items: Results<Item>!
    var categorys: [Category] = [
        Category(name: "Outer"),
        Category(name: "Top"),
        Category(name: "Bottom"),
        Category(name: "Shoes"),
        Category(name: "Acc")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        items = database.getAllDatas(Item.self, keyPath: "orderDate")
        configureNaviItem()
        configureCollectionView()
        configureDataSource()
        applySnapshot()
        
        print("FileURL: \(database.getRealmURL())")
    }
}

extension MainViewController {
    
    private func configureNaviItem() {
        navigationItem.title = "Main"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(tappedAddButton))
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self
        view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func createLayout() -> UICollectionViewLayout {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .grouped)
        listConfiguration.showsSeparators = false
        listConfiguration.trailingSwipeActionsConfigurationProvider = makeSwipeAction
        return UICollectionViewCompositionalLayout.list(using: listConfiguration)
    }

    private func makeSwipeAction(for indexPath: IndexPath?) -> UISwipeActionsConfiguration? {
        guard let indexPath = indexPath, let id = datasource.itemIdentifier(for: indexPath) else { return nil }
        let deleteActionTitle = NSLocalizedString("Delete", comment: "Delete Action Title")
        let deleteAction = UIContextualAction(style: .destructive, title: deleteActionTitle) { [weak self] _, _, completion in
            self?.deleteItem(withID: id)
            self?.applySnapshot()
            completion(false)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    private func configureDataSource() {
        
        let cellRegistration = UICollectionView.CellRegistration(handler: cellRegistrationHandler)
        
        datasource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        })
    }
    
    func applySnapshot(reloading ids: [Item.ID] = []) {
        snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(items.map { $0.id })
        if !ids.isEmpty {
            snapshot.reloadItems(ids)
        }
        datasource.apply(snapshot)
    }
    
    @objc func tappedAddButton(_ sender: UIBarButtonItem) {
        let item = Item(name: "")
        let vc = EditViewController(item: item, isAdd: true)
        
        vc.itemChangeHandler = { [weak self] item in
            self?.database.add(item) { [weak self] in
                self?.applySnapshot()
                print("MainViewController - item Added")
            }
        }
        vc.navigationItem.title = NSLocalizedString("Add Item", comment: "Add Item view controller title")
        vc.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(tappedCancelButton(_:)))
        let nvc = UINavigationController(rootViewController: vc)
        present(nvc, animated: true)
    }
    
    @objc private func tappedCancelButton(_ sender:UIBarButtonItem) {
        dismiss(animated: true)
    }
}

extension MainViewController {
    
    private func cellRegistrationHandler(cell: UICollectionViewListCell, indexPath: IndexPath, id: Item.ID) {
        let item = item(withID: id)
        
        var content = cell.defaultContentConfiguration()
        content.text = item.name
        content.secondaryText = item.brand + " • " + item.category + " • " + item.size + " • " + item.satisfaction
        content.secondaryTextProperties.font = .preferredFont(forTextStyle: .caption1)
        cell.contentConfiguration = content
        
        var backgroundContent = UIBackgroundConfiguration.listGroupedCell()
        backgroundContent.backgroundColor = .systemGroupedBackground
        cell.backgroundConfiguration = backgroundContent
        
    }
    
    private func item(withID id: Item.ID) -> Item {
        let index = items.indexOfItem(with: id)
        return items[index]
    }
    
    func deleteItem(withID id: Item.ID) {
        let item = item(withID: id)
        database.delete(item) { [weak self] in
            self?.applySnapshot()
        }
    }
}

extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let id = datasource.itemIdentifier(for: indexPath) else { return }
        let item = item(withID: id)
        let vc = DetailViewController(item: item) { [weak self] item in
            self?.applySnapshot(reloading: [item.id])
            print("MainViewController - item Updated")
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}
