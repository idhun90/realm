//
//  DetailViewController.swift
//  realm
//
//  Created by 도헌 on 2023/02/19.
//

import UIKit

final class DetailViewController: UIViewController {

enum Section: Int, Hashable {
    case main
}

enum Row: Hashable {
    case name
    case category
    case brand
    case size
    case fit
    case satisfaction
    case color
    case price
    case orderDate
    case url
    case note

    var imageName: String? {
        switch self {
        case .name: return nil
        case .category: return "list.bullet.circle"
        case .brand: return "b.circle"
        case .size: return "ruler"
        case .fit: return "square.on.square"
        case .satisfaction: return "star"
        case .color: return "paintpalette"
        case .price: return "wonsign.circle"
        case .orderDate: return "calendar.circle"
        case .url: return "link.circle"
        case .note: return "note.text"
        }
    }
    
    var image: UIImage? {
        guard let imageName = imageName else { return nil }
        let configuration = UIImage.SymbolConfiguration(textStyle: .headline)
        return UIImage(systemName: imageName, withConfiguration: configuration)
    }
    
    var textStyle: UIFont.TextStyle {
        switch self {
        case .name : return .headline
        default : return .subheadline
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
    var onChange: (Item) -> Void
    
    var onchangeCustomCategorys: (([Category]) -> Void) = { _ in }
    var onchangeCustomBrands: (([Brand]) -> Void) = { _ in }
    var onchangeCustomColors: (([Color]) -> Void) = { _ in }
    var onchangeCustomFits: (([Fit]) -> Void) = { _ in }
    var onchangeCustomSatisfactions: (([Satisfaction]) -> Void) = { _ in }
    var onchangeCustomSizes: (([Size]) -> Void) = { _ in }
    
    init(item: Item, onChange: @escaping (Item) -> Void) {
        self.item = item
        self.editingItem = item
        self.onChange = onChange
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavibarItem()
        configureCollectionView()
        configureDataSource()
        applySnapshot()
    }

    private func configureNavibarItem() {
        navigationItem.title = "Detail"
        let rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(tappedEditButton))
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    @objc private func tappedEditButton() {
        let viewController = EditViewController(item: editingItem, isAdd: false)
        viewController.itemChangeHandler = { [weak self] item in
            guard let self = self else { return }
            self.database.update(old: self.editingItem, new: item) {
                self.updateSnapshot()
                print("DetailViewController - item Updated")
                self.onChange(self.editingItem)
            }
        }
        viewController.navigationItem.title = "Edit"
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(tappedCancelButton(_:)))
        let nvc = UINavigationController(rootViewController: viewController)
        present(nvc, animated: true)
    }
    
    @objc private func tappedCancelButton(_ sender:UIBarButtonItem) {
        dismiss(animated: true)
    }
}

extension DetailViewController {
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: creatLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.delegate = self
        collectionView.allowsSelection = false
        view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.0),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0)
        ])
    }
    
    private func creatLayout() -> UICollectionViewLayout {
        var listConfiguraiton = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        listConfiguraiton.showsSeparators = false
        return UICollectionViewCompositionalLayout.list(using: listConfiguraiton)
    }
    
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Row>(handler: cellRegistrationHandler)
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, row in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: row)
        })
    }
    
    private func applySnapshot() {
        snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems([Row.name, Row.category, Row.brand, Row.fit, Row.satisfaction, Row.size, Row.color, Row.price, Row.orderDate, Row.url, Row.note])
        dataSource.apply(snapshot)
    }
    
    private func updateSnapshot() {
        var newSnapshot = dataSource.snapshot()
        newSnapshot.reloadSections([.main])
        dataSource.apply(newSnapshot, animatingDifferences: false)
    }

}
//MARK: - CellRegistration
extension DetailViewController {
    private func cellRegistrationHandler(cell: UICollectionViewListCell, indexPath: IndexPath, row: Row) {
        cell.contentConfiguration = listConfiguration(for: cell, at: row)
    }
}

extension DetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
    }
}

