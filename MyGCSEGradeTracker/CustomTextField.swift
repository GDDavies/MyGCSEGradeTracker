//
//  CustomTextField.swift
//  MyGCSEGradeTracker
//
//  Created by George Davies on 05/01/2017.
//  Copyright © 2017 George Davies. All rights reserved.
//
import Foundation
import UIKit

@IBDesignable
class CustomTextField: UITextField {

    @IBInspectable var paddingLeft: CGFloat = 0
    @IBInspectable var paddingRight: CGFloat = 10
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + paddingLeft, y: bounds.origin.y, width: bounds.size.width - paddingLeft - paddingRight, height: bounds.size.height)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if (action == #selector(UIResponderStandardEditActions.paste(_:))) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}

