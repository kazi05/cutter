//
//  SimpleColorPickerViewController.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 18.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import UIKit
import FlexColorPicker

final class SimpleColorPickerViewController: DefaultColorPickerViewController {
    
    private var myTextField: UITextField!
    
    /// This is required for the inputAccessoryView to work.
    override internal var canBecomeFirstResponder: Bool {
        return true
    }
    
    /// Here's a nice empty red view that will be used as an
    /// input accessory.
    private lazy var accessoryView: UIView = {
        let accessoryView = UIView()
        accessoryView.backgroundColor = UIColor(named: "bgColor")
        accessoryView.frame.size = CGSize(
            width: view.frame.size.width,
            height: 45
        )
        accessoryView.alpha = 0
        
        myTextField = UITextField(frame: accessoryView.bounds)
        myTextField.returnKeyType = .done
        myTextField.textAlignment = .center
        myTextField.keyboardType = .asciiCapable
        myTextField.textColor = .white
        myTextField.font = .systemFont(ofSize: 17, weight: .bold)
        myTextField.delegate = self
        accessoryView.addSubview(myTextField)
        
        return accessoryView
    } ()
    
    override var inputAccessoryView: UIView? {
        return accessoryView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "navBarColor")
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(colorPreviewTapped))
        colorPreview.addGestureRecognizer(tapGesture)
        
        let endEditingTap = UITapGestureRecognizer(target: self, action: #selector(viewEndEditingTap))
        view.addGestureRecognizer(endEditingTap)
    }
    
    // MARK: - Selectors ⚡️
    @objc
    private func colorPreviewTapped(_ tapGesture: UITapGestureRecognizer) {
        myTextField.becomeFirstResponder()
    }
    
    @objc
    private func viewEndEditingTap(_ tapGesture: UITapGestureRecognizer) {
        myTextField.resignFirstResponder()
    }
    
    // MARK: - Actions ⚡️
    @IBAction func acrionCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionChooseColor(_ sender: Any) {
        dismiss(animated: true)
        delegate?.colorPicker(colorPicker, confirmedColor: colorPicker.selectedColor, usingControl: colorPicker.colorControls.first!)
    }
    
}

extension SimpleColorPickerViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3) {
            self.accessoryView.alpha = 1
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3) {
            self.accessoryView.alpha = 0
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var formattedString = string
        if formattedString.contains("#") && formattedString.count > 1 {
            formattedString = String(formattedString.dropFirst())
        }
        let hexRegex = "^[A-Fa-f\\d#]{1,6}$"
        let swiftRange = Range(range)
        
        if string == "" {
            textField.deleteBackward()
        } else {
            if (string == " ") || textField.text!.count > 6 || !(formattedString.matches(hexRegex)) {
                return false
            }
            
            if string.count > 1 {
                if !formattedString.contains("#") {
                    formattedString.insert("#", at: formattedString.startIndex)
                }
            } else if (swiftRange?.startIndex ?? 1) == 0 && string != "#" {
                textField.insertText("#")
            }
        
            textField.insertText(formattedString.uppercased())
        }
        return false
    }
}

fileprivate extension String {
    func matches(_ regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
}
