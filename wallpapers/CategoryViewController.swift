//
//  CategoryViewController.swift
//  wallpapers
//
//  Created by Evan Latner on 11/9/17.
//  Copyright © 2017 levellabs. All rights reserved.
//

import UIKit
import PickerView

class CategoryViewController: UIViewController, PickerViewDelegate, PickerViewDataSource {

    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var pickerView: PickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.reloadPickerView()
        pickerView.backgroundColor = UIColor.clear
        pickerView.currentSelectedRow = 0//abs(Int(CategoryManager.Instance.categories.count/2))
        doneButton.layer.cornerRadius = 24
        doneButton.addBounce()
    }
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        CategoryManager.Instance.currentCategory = CategoryManager.Instance.categories[pickerView.currentSelectedRow]
        dismiss()
    }
    
    func pickerViewNumberOfRows(_ pickerView: PickerView) -> Int {
        return CategoryManager.Instance.categories.count
    }
    
    func pickerView(_ pickerView: PickerView, titleForRow row: Int, index: Int) -> String {
        return CategoryManager.Instance.categories[index]
    }
    
    func pickerViewHeightForRows(_ pickerView: PickerView) -> CGFloat {
        return 50.0
    }
    
    func pickerView(_ pickerView: PickerView, didSelectRow row: Int) {
//        let generator = UIImpactFeedbackGenerator(style: .light)
//        generator.impactOccurred()
    }
    
    func pickerView(_ pickerView: PickerView, didTapRow row: Int, index: Int) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    func pickerView(_ pickerView: PickerView, styleForLabel label: UILabel, highlighted: Bool) {
        label.textAlignment = .center
        
        if highlighted {
            label.font = UIFont(name: "AvenirNext-Bold", size: 26)
            label.textColor = UIColor.white
        } else {
            label.font = UIFont(name: "AvenirNext-Bold", size: 16)
            label.textColor = UIColor.lightGray
        }
    }
    
    func dismiss () {
        dismiss(animated: false, completion: nil)
    }
}
