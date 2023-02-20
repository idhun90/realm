//
//  EditViewController + Configuration.swift
//  realm
//
//  Created by 도헌 on 2023/02/20.
//

import UIKit

extension EditViewController {
    
    func editListConfiguration(for cell: UICollectionViewListCell, with value: String?, at row: Row) -> UIListContentConfiguration {
        var contentConfiguration = UIListContentConfiguration.valueCell()
        contentConfiguration.text = text(for: row)
        contentConfiguration.secondaryText = value
        return contentConfiguration
    }
    
    func datePickerConfiguration(for cell: UICollectionViewListCell, with Date: Date) -> DatePickerContentView.Configuration {
        var contentConfiguration = cell.DatePickerContentConfiguration()
        contentConfiguration.date = Date
        contentConfiguration.onchange = { [weak self] date in
            self?.editingItem.orderDate = date
            print("EditView - orderDate Changed")
        }
        return contentConfiguration
    }
    
    func textFieldConfiguration(for cell: UICollectionViewListCell, with text: String?, placeholder: String?, row: Row) -> TextFieldContentView.Configuration {
        var contentConfiguration = cell.textFieldConfiguration()
        contentConfiguration.text = configureTextFieldText(row: row, text: text)
        contentConfiguration.placeholder = placeholder
        contentConfiguration.textColor = configureTextFieldTextColor(row: row)
        contentConfiguration.keyboardType = configureTextFieldKeyboardType(row: row)
        contentConfiguration.onChange = { [weak self] text in
            guard let self = self else { return }
            switch row {
            case .editName(_):
                self.editingItem.name = text
                print("EditView - name Changed")
            case .editPrice(_):
                print(text)
                self.editingItem.price = self.addDecimalNumberFormat(with: text) // ❌ why no display decimalNumberFormat?
                print(self.addDecimalNumberFormat(with: text)) // worked but no display
                print("EditView - price Changed")
            case .editUrl(_):
                self.editingItem.url = text
                print("EditView - url Changed")
            default: fatalError("TextField error")
            }
        }
        return contentConfiguration
    }
    
    func textViewConfiguration(for cell: UICollectionViewListCell, with note: String) -> TextViewContentView.Configuration {
        var contentConfiguration = cell.TextViewConfiguration()
        contentConfiguration.text = configurePlaceholder(with: note)
        contentConfiguration.textColor = configureTextViewTextColor(with: note)
        contentConfiguration.onchange = { [weak self] note in
            self?.editingItem.note = note
            print("EditView - Note Changed")
        }
        return contentConfiguration
    }
    
    private func configurePlaceholder(with note: String) -> String {
        if note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Note"
        } else {
            return note
        }
    }
    
    private func configureTextViewTextColor(with note: String) -> UIColor? {
        if note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || note == "Note" {
            return .placeholderText
        } else {
            return .label
        }
    }
    
    private func configureTextFieldText(row: Row, text: String?) -> String? {
        switch row {
        case .editName(_): return text
        case .editPrice(_): return addDecimalNumberFormat(with: text ?? "")
        case .editUrl(_): return text
        default: return nil
        }
    }
    
    private func configureTextFieldTextColor(row: Row) -> UIColor? {
        switch row {
        case .editName(_): return .label
        case .editPrice(_): return .label
        case .editUrl(_): return .link
        default: return nil
        }
    }
    
    private func configureTextFieldKeyboardType(row: Row) -> UIKeyboardType {
        switch row {
        case .editName(_): return .default
        case .editPrice(_): return .decimalPad
        case .editUrl(_): return .URL
        default: fatalError("TextField KeyboardType Erorr")
        }
    }
    
    private func addDecimalNumberFormat(with text: String) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let priceText = text.replacingOccurrences(of: ",", with: "")
        guard let priceDouble = Double(priceText) else { return "" }
        guard let price = numberFormatter.string(for: priceDouble) else { return "" }
        return price
    }
    
    func text(for row: Row) -> String? {
        switch row {
        case .editName(_): return Row.editName("").text
        case .editCategory(_): return Row.editCategory("").text
        case .editBrand(_): return Row.editBrand("").text
        case .editSize(_): return Row.editSize("").text
        case .editColor(_): return Row.editColor("").text
        case .editFit(_): return Row.editFit("").text
        case .editSatisfaction(_): return Row.editSatisfaction("").text
        case .editPrice(_): return Row.editPrice("").text
        case .editOrderDate(_): return Row.editOrderDate(Date()).text
        case .editUrl(_): return Row.editUrl("").text
        case .editNote(_): return Row.editNote("").text
        }
    }
}
