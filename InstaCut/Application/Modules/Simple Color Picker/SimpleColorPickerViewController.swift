//
//  SimpleColorPickerViewController.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 18.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import UIKit
import FlexColorPicker

class SimpleColorPickerViewController: DefaultColorPickerViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(named: "navBarColor")
    }
    
    @IBAction func acrionCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
