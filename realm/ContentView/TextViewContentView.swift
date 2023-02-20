//
//  TextViewContentView.swift
//  realm
//
//  Created by 도헌 on 2023/02/15.
//

import UIKit

final class TextViewContentView: UIView, UIContentView {
    
    struct Configuration: UIContentConfiguration {
        
        var text: String = ""
        var textColor: UIColor?
        var onchange: (String) -> Void = { _ in }
        
        func makeContentView() -> UIView & UIContentView {
            return TextViewContentView(self)
        }
    }
    
    let textView = UITextView()
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
        addCommonSubView(textView, height: 200, insets: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 20))
        textView.backgroundColor = nil
        textView.font = .preferredFont(forTextStyle: .body)
        textView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(configuration: UIContentConfiguration) {
        guard let configuration = configuration as? Configuration else { return }
        textView.text = configuration.text
        textView.textColor = configuration.textColor
    }
}

extension UICollectionViewListCell {
    func TextViewConfiguration() -> TextViewContentView.Configuration {
        TextViewContentView.Configuration()
    }
}

extension TextViewContentView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        guard let configuration = configuration as? TextViewContentView.Configuration else { return }
        configuration.onchange(textView.text)
    }
    
    //MARK: - textView Placeholder
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text.isEmpty || textView.text == "Note" {
            textView.text = nil
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || textView.text == "Note" {
            textView.text = "Note"
            textView.textColor = .placeholderText
        }
    }
}

