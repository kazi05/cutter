//
//  ProgressColorPickerPresenter.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 18.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import UIKit

protocol ProgressColorPickerPresenterOutput: class {
    func colorChanged(_ color: UIColor)
    func colorChoosed(_ color: UIColor)
    func colorRemoved()
    func canceled()
}

class ProgressColorPickerPresenter {
    
    // MARK: - Private properties 🕶
    private weak var view: ProgressColorPickerView!
    private weak var delegate: ProgressColorPickerPresenterOutput!
    private let pickedColor: UIColor?
    private var changedColor: UIColor!
    
    // MARK: - Constructor 🏗
    init(view: ProgressColorPickerView, delegate: ProgressColorPickerPresenterOutput, color: UIColor?) {
        self.view = view
        self.delegate = delegate
        self.pickedColor = color
        
    }
    
    // MARK: - View actions
    func viewDidLoad() {
        view.setSelectedColor(color: pickedColor)
    }
    
    func changeColor(color: UIColor) {
        changedColor = color
        delegate.colorChanged(color)
    }
    
    func colorChoosed() {
        delegate.colorChoosed(changedColor)
    }
    
    func colorRemoved() {
        delegate.colorRemoved()
    }
    
    func cancelPicker() {
        delegate.canceled()
    }
    
    func getCurrentColor() -> UIColor? {
        return changedColor
    }
    
}
