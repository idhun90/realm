//
//  SelectFitController.swift
//  realm
//
//  Created by 도헌 on 2023/02/19.
//

import UIKit

import RealmSwift

final class SelectFitViewController: UIViewController {
    
    enum listSection: Int {
        case defaultList
        case customList
    }
    
    let defaultFits = [
        Fit(name: "Slim"),
        Fit(name: "Regular"),
        Fit(name: "SemiOver"),
        Fit(name: "Over")
    ]
    var customFits: Results<Fit>!
    var selectedID: Fit.ID!
    var item: Item
    
    var onchangeFit: ((String) -> Void) = { _ in }
        
    private let database = RealmManager.shared

    init(item: Item) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private typealias DataSource = UICollectionViewDiffableDataSource<listSection, Fit.ID>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<listSection, Fit.ID>
    
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
        customFits = database.getAllDatas(Fit.self, keyPath: "createdDate")
        selectedID = getFitID(withName: item.fit)
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
            self?.deleteFit(withID: id)
            self?.applySnapshot()
            completion(false)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    private func configureDataSource() {
        let cellRegistraion = UICollectionView.CellRegistration<UICollectionViewListCell, Fit.ID> { [weak self] cell, indexPath, itemIdentifier in
            guard let self = self else { return }
            var contentConfiguration = UIListContentConfiguration.valueCell()
            contentConfiguration.text = self.getFit(withID: itemIdentifier).name
            cell.contentConfiguration = contentConfiguration
            
            cell.accessories = itemIdentifier == self.selectedID ? [.checkmark(displayed: .always)] : []
        }
        
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistraion, for: indexPath, item: itemIdentifier)
        })
    }
    
    private func applySnapshot(reloading ids: [Fit.ID] = []) {
        snapshot = Snapshot()
        snapshot.appendSections([.defaultList, .customList])
        snapshot.appendItems(defaultFits.map { $0.id }, toSection: .defaultList)

        snapshot.appendItems(customFits.map { $0.id }, toSection: .customList)
        if !ids.isEmpty {
            snapshot.reloadItems(ids)
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
extension SelectFitViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        updateSelectedId(collectionView: collectionView, indexPath: indexPath)
    }
    
    private func updateSelectedId(collectionView: UICollectionView, indexPath: IndexPath) {
        guard let currentSelectedId = dataSource.itemIdentifier(for: indexPath) else { return }
        
        guard selectedID != currentSelectedId else { return }
        selectedID = currentSelectedId
        
        var newSnapshot = dataSource.snapshot()
        newSnapshot.reconfigureItems(defaultFits.map { $0.id })
        newSnapshot.reconfigureItems(customFits.map { $0.id })
        dataSource.apply(newSnapshot, animatingDifferences: false)
        
        print("selected:", getFit(withID: currentSelectedId).name)
        onchangeFit(getFit(withID: currentSelectedId).name)
    }
}

extension SelectFitViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text else { return false }

        if validationText(with: text) {
            let modifiedText = text.trimmingCharacters(in: .whitespaces)
            database.add(Fit(name: modifiedText)) {[weak self] in
                self?.applySnapshot()
            }
        }
        textField.text = nil
        return true
    }

    private func validationText(with text: String) -> Bool {
        let removedWhitespacesText = text.replacingOccurrences(of: " ", with: "") // 중복 검사를 위해 모든 공백 제거 removeAllspaceForTest
        let isEmpty = removedWhitespacesText.isEmpty // 모든 공백 제거 후 빈값인지 체크, checkIsEmpty
        let isDuplication = customFits.contains(where: { $0.name.replacingOccurrences(of: " ", with: "").caseInsensitiveCompare(removedWhitespacesText) == .orderedSame})// 모든 공백 제거한 값끼리 대소문자 구분 없이 같은 값을 가지고 있는지 체크
        return !isEmpty && !isDuplication
        
    }
}

extension SelectFitViewController {

    private func getFitID(withName name: String) -> Fit.ID {
        guard let customFit = customFits.first(where: { $0.name == name }) else {
            guard let defaultFit = defaultFits.first(where: { $0.name == name } ) else { fatalError("no have maching fitName") }
            return defaultFit.id
        }
        return customFit.id
    }
    
    private func getFit(withID id: Fit.ID) -> Fit {
        guard let customIndex = customFits.firstIndex(where: { $0.id == id }) else {
            guard let defaultIndex = defaultFits.firstIndex(where: { $0.id == id } ) else { fatalError("no have maching fitID") }
            return defaultFits[defaultIndex]
        }
        return customFits[customIndex]
    }
    
    private func deleteFit(withID id: Fit.ID) {
        if selectedID == id {
            selectedID = getFitID(withName: "Regular")
            let selectedFit = getFit(withID: selectedID)
            onchangeFit(selectedFit.name)
            
            var newSnapshot = dataSource.snapshot()
            newSnapshot.reconfigureItems(defaultFits.map { $0.id })
            newSnapshot.reconfigureItems(customFits.map { $0.id })
            dataSource.apply(newSnapshot, animatingDifferences: false)

        }
        let fit = customFits.getFit(withID: id)
        print("deleted: \(fit.name)")
        database.delete(fit)
    }
}
