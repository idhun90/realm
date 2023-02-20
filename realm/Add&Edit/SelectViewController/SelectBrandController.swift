//
//  SelectBrandViewController.swift
//  realm
//
//  Created by 도헌 on 2023/02/15.
//

import UIKit

import RealmSwift

final class SelectBrandViewController: UIViewController {
    
    enum listSection: Int {
        case defaultList
        case customList
    }
    
    let defaultBrand = [Brand(name: "None")]
    var customBrands: Results<Brand>!
    var selectedID: Brand.ID!
    var item: Item
    
    var onchangeBrand: ((String) -> Void) = { _ in }
        
    private let database = RealmManager.shared

    init(item: Item) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private typealias DataSource = UICollectionViewDiffableDataSource<listSection, Brand.ID>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<listSection, Brand.ID>
    
    let addTextField: UITextField = {
        let view = UITextField()
        view.placeholder = "Add Custom"
        view.backgroundColor = .secondarySystemGroupedBackground
        view.leftViewMode = .always
        view.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 44))
        view.layer.cornerRadius = 10
        view.clearButtonMode = .whileEditing
        view.autocapitalizationType = .none
        view.layer.shadowOpacity = 0.18
        view.layer.shadowOffset = CGSize.zero
        return view
    }()
    
    private var collectionView: UICollectionView!
    private var dataSource: DataSource!
    private var snapshot: Snapshot!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        dataDidLoad()
        configureCollectionView()
        configureUI()
        configureDataSource()
        applySnapshot()
        isModalInPresentation = true
    }
    
    private func dataDidLoad() {
        customBrands = database.getAllDatas(Brand.self, keyPath: "createdDate")
        selectedID = getBrandID(withName: item.brand)
    }

    private func configureUI() {
        addTextField.delegate = self
        view.addSubview(addTextField)
        
        addTextField.translatesAutoresizingMaskIntoConstraints = false
        let spacing: CGFloat = 10
        NSLayoutConstraint.activate([
            addTextField.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -spacing),
            addTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: spacing),
            addTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -spacing),
            addTextField.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self
        collectionView.keyboardDismissMode = .onDrag
        view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func createLayout() -> UICollectionViewLayout {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        listConfiguration.trailingSwipeActionsConfigurationProvider = makeSwipeActions
        return UICollectionViewCompositionalLayout.list(using: listConfiguration)
    }
    
    private func makeSwipeActions(for indexPath: IndexPath?) -> UISwipeActionsConfiguration? {
        guard let indexPath = indexPath, let id = dataSource.itemIdentifier(for: indexPath) else { return nil }
        guard indexPath.section != 0 else { return nil }
        let deleteActionName = NSLocalizedString("Delete", comment: "Delete action title")
        let deleteAction = UIContextualAction(style: .destructive, title: deleteActionName) { [weak self] _, _, completion in
            self?.deleteBrand(withID: id)
            self?.applySnapshot()
            completion(false)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    private func configureDataSource() {
        let cellRegistraion = UICollectionView.CellRegistration<UICollectionViewListCell, Brand.ID> { [weak self] cell, indexPath, itemIdentifier in
            guard let self = self else { return }
            var contentConfiguration = UIListContentConfiguration.valueCell()
            contentConfiguration.text = self.getBrand(withID: itemIdentifier).name
            cell.contentConfiguration = contentConfiguration
            
            cell.accessories = itemIdentifier == self.selectedID ? [.checkmark(displayed: .always)] : []
        }
        
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistraion, for: indexPath, item: itemIdentifier)
        })
    }
    
    private func applySnapshot(reloading ids: [Brand.ID] = []) {
        snapshot = Snapshot()
        snapshot.appendSections([.defaultList, .customList])
        snapshot.appendItems(defaultBrand.map { $0.id }, toSection: .defaultList)

        snapshot.appendItems(customBrands.map { $0.id }, toSection: .customList)
        if !ids.isEmpty {
            snapshot.reloadItems(ids)
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
extension SelectBrandViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        updateSelectedId(collectionView: collectionView, indexPath: indexPath)
    }
    
    private func updateSelectedId(collectionView: UICollectionView, indexPath: IndexPath) {
        guard let currentSelectedId = dataSource.itemIdentifier(for: indexPath) else { return }
        
        guard selectedID != currentSelectedId else { return }
        selectedID = currentSelectedId
        
        var newSnapshot = dataSource.snapshot()
        newSnapshot.reconfigureItems(defaultBrand.map { $0.id })
        newSnapshot.reconfigureItems(customBrands.map { $0.id })
        dataSource.apply(newSnapshot, animatingDifferences: false)
        
        print("selected:", getBrand(withID: currentSelectedId).name)
        onchangeBrand(getBrand(withID: currentSelectedId).name)
    }
}

extension SelectBrandViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text else { return false }

        if validationText(with: text) {
            let modifiedText = text.trimmingCharacters(in: .whitespaces)
            database.add(Brand(name: modifiedText)) {[weak self] in
                self?.applySnapshot()
            }
        }
        textField.text = nil
        return true
    }

    private func validationText(with text: String) -> Bool {
        let removedWhitespacesText = text.replacingOccurrences(of: " ", with: "") // 중복 검사를 위해 모든 공백 제거 removeAllspaceForTest
        let isEmpty = removedWhitespacesText.isEmpty // 모든 공백 제거 후 빈값인지 체크, checkIsEmpty
        let isDuplication = customBrands.contains(where: { $0.name.replacingOccurrences(of: " ", with: "").caseInsensitiveCompare(removedWhitespacesText) == .orderedSame})// 모든 공백 제거한 값끼리 대소문자 구분 없이 같은 값을 가지고 있는지 체크
        return !isEmpty && !isDuplication
        
    }
}

extension SelectBrandViewController {

    private func getBrandID(withName name: String) -> Brand.ID {
        guard let customBrand = customBrands.first(where: { $0.name == name }) else {
            guard let defaultBrand = defaultBrand.first(where: { $0.name == name } ) else { fatalError("no have maching brandName") }
            return defaultBrand.id
        }
        return customBrand.id
    }
    
    private func getBrand(withID id: Brand.ID) -> Brand {
        guard let customIndex = customBrands.firstIndex(where: { $0.id == id }) else {
            guard let defaultIndex = defaultBrand.firstIndex(where: { $0.id == id } ) else { fatalError("no have maching brandID") }
            return defaultBrand[defaultIndex]
        }
        return customBrands[customIndex]
    }
    
    private func deleteBrand(withID id: Brand.ID) {
        if selectedID == id {
            selectedID = getBrandID(withName: "None")
            let selectedBrand = getBrand(withID: selectedID)
            onchangeBrand(selectedBrand.name)
            
            var newSnapshot = dataSource.snapshot()
            newSnapshot.reconfigureItems(defaultBrand.map { $0.id })
            newSnapshot.reconfigureItems(customBrands.map { $0.id })
            dataSource.apply(newSnapshot, animatingDifferences: false)

        }
        let brand = customBrands.getBrand(withID: id)
        print("deleted: \(brand.name)")
        database.delete(brand)
    }
}


