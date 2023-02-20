//
//  TextFieldContentView.swift
//  realm
//
//  Created by 도헌 on 2023/02/15.
//

import UIKit

final class TextFieldContentView: UIView, UIContentView {

    struct Configuration: UIContentConfiguration {
        
        var text: String? = ""
        var textColor: UIColor?
        var placeholder: String?
        var keyboardType: UIKeyboardType = .default
        var onChange: (String) -> Void = { _ in }
        
        func makeContentView() -> UIView & UIContentView {
            return TextFieldContentView(self)
        }
    }
    
    let textField = UITextField()
    var configuration: UIContentConfiguration {
        didSet {
            configure(configuration: configuration)
        }
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: 0, height: 44)
    }
    
    init(_ configuration: UIContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        addCommonSubView(textField)
        textField.clearButtonMode = .whileEditing
        textField.autocapitalizationType = .none
        textField.addTarget(self, action: #selector(didChange(_:)), for: .editingChanged)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(configuration: UIContentConfiguration) {
        guard let configuration = configuration as? Configuration else { return }
        textField.text = configuration.text
        textField.textColor = configuration.textColor
        textField.placeholder = configuration.placeholder
        textField.keyboardType = configuration.keyboardType
    }
    
    @objc private func didChange(_ sender: UITextField) {
        guard let configuration = configuration as? TextFieldContentView.Configuration else { return }
        configuration.onChange(sender.text ?? "")
    }
}

extension UICollectionViewListCell {
    func textFieldConfiguration() -> TextFieldContentView.Configuration {
        TextFieldContentView.Configuration()
    }
}

