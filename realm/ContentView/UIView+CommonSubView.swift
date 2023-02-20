//
//  UIView+CommonSubView.swift
//  realm
//
//  Created by 도헌 on 2023/02/15.
//

import UIKit

extension UIView {
    func addCommonSubView(_ subView: UIView, height: CGFloat? = nil, insets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)) {
        addSubview(subView)
        subView.translatesAutoresizingMaskIntoConstraints = false
        subView.topAnchor.constraint(equalTo: topAnchor, constant: insets.top).isActive = true
        subView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1.0*insets.bottom).isActive = true
        subView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left).isActive = true
        subView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -1.0*insets.right).isActive = true
        
        if let height {
            subView.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}

