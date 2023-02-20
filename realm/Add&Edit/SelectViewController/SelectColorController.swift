//
//  SelectColorController.swift
//  realm
//
//  Created by 도헌 on 2023/02/19.
//

import UIKit

import RealmSwift

final class SelectColorViewController: UIViewController {
    
    enum listSection: Int {
        case defaultList
        case customList
    }
    
    let defaultColor = [Color(name: "None")]
    var customColors: Results<Color>!
    var selectedID: Color.ID!
    var item: Item
    
    var onchangeColor: ((String) -> Void) = { _ in }
        
    private let database = RealmManager.shared

    init(item: Item) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private typealias DataSource = UICollectionViewDiffableDataSource<listSection, Color.ID>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<listSection, Color.ID>
    
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
        customColors = database.getAllDatas(Color.self, keyPath: "createdDate")
        selectedID = getColorID(withName: item.color)
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
            self?.deleteColor(withID: id)
            self?.applySnapshot()
            completion(false)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    private func configureDataSource() {
        let cellRegistraion = UICollectionView.CellRegistration<UICollectionViewListCell, Color.ID> { [weak self] cell, indexPath, itemIdentifier in
            guard let self = self else { return }
            var contentConfiguration = UIListContentConfiguration.valueCell()
            contentConfiguration.text = self.getColor(withID: itemIdentifier).name
            cell.contentConfiguration = contentConfiguration
            
            cell.accessories = itemIdentifier == self.selectedID ? [.checkmark(displayed: .always)] : []
        }
        
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistraion, for: indexPath, item: itemIdentifier)
        })
    }
    
    private func applySnapshot(reloading ids: [Color.ID] = []) {
        snapshot = Snapshot()
        snapshot.appendSections([.defaultList, .customList])
        snapshot.appendItems(defaultColor.map { $0.id }, toSection: .defaultList)

        snapshot.appendItems(customColors.map { $0.id }, toSection: .customList)
        if !ids.isEmpty {
            snapshot.reloadItems(ids)
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
extension SelectColorViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        updateSelectedId(collectionView: collectionView, indexPath: indexPath)
    }
    
    private func updateSelectedId(collectionView: UICollectionView, indexPath: IndexPath) {
        guard let currentSelectedId = dataSource.itemIdentifier(for: indexPath) else { return }
        
        guard selectedID != currentSelectedId else { return }
        selectedID = currentSelectedId
        
        var newSnapshot = dataSource.snapshot()
        newSnapshot.reconfigureItems(defaultColor.map { $0.id })
        newSnapshot.reconfigureItems(customColors.map { $0.id })
        dataSource.apply(newSnapshot, animatingDifferences: false)
        
        print("selected:", getColor(withID: currentSelectedId).name)
        onchangeColor(getColor(withID: currentSelectedId).name)
    }
}

extension SelectColorViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text else { return false }

        if validationText(with: text) {
            let modifiedText = text.trimmingCharacters(in: .whitespaces)
            database.add(Color(name: modifiedText)) {[weak self] in
                self?.applySnapshot()
            }
        }
        textField.text = nil
        return true
    }

    private func validationText(with text: String) -> Bool {
        let removedWhitespacesText = text.replacingOccurrences(of: " ", with: "") // 중복 검사를 위해 모든 공백 제거 removeAllspaceForTest
        let isEmpty = removedWhitespacesText.isEmpty // 모든 공백 제거 후 빈값인지 체크, checkIsEmpty
        let isDuplication = customColors.contains(where: { $0.name.replacingOccurrences(of: " ", with: "").caseInsensitiveCompare(removedWhitespacesText) == .orderedSame})// 모든 공백 제거한 값끼리 대소문자 구분 없이 같은 값을 가지고 있는지 체크
        return !isEmpty && !isDuplication
        
    }
}

extension SelectColorViewController {

    private func getColorID(withName name: String) -> Color.ID {
        guard let customColor = customColors.first(where: { $0.name == name }) else {
            guard let defaultColor = defaultColor.first(where: { $0.name == name } ) else { fatalError("no have maching colorName") }
            return defaultColor.id
        }
        return customColor.id
    }
    
    private func getColor(withID id: Color.ID) -> Color {
        guard let customIndex = customColors.firstIndex(where: { $0.id == id }) else {
            guard let defaultIndex = defaultColor.firstIndex(where: { $0.id == id } ) else { fatalError("no have maching colorID") }
            return defaultColor[defaultIndex]
        }
        return customColors[customIndex]
    }
    
    private func deleteColor(withID id: Color.ID) {
        if selectedID == id {
            selectedID = getColorID(withName: "None")
            let selectedColor = getColor(withID: selectedID)
            onchangeColor(selectedColor.name)
            
            var newSnapshot = dataSource.snapshot()
            newSnapshot.reconfigureItems(defaultColor.map { $0.id })
            newSnapshot.reconfigureItems(customColors.map { $0.id })
            dataSource.apply(newSnapshot, animatingDifferences: false)

        }
        let color = customColors.getColor(withID: id)
        print("deleted: \(color.name)")
        database.delete(color)
    }
}
