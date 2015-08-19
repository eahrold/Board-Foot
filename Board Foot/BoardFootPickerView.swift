//
//  BoardPickerView.swift
//  Board Foot
//
//  Created by Eldon on 7/6/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//

import UIKit

class BoardFootThicknessPickerView: UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    private let thicknesses = ["4/4", "5/4", "6/4", "7/4", "8/4"]

    var thicknessChangeHandle:(() -> Void)?
    
    var selectedThicknessValue: Double {
        let t = thicknesses[self.selectedRowInComponent(0)]
        let a = t.componentsSeparatedByString("/") as Array;
        if let num = a.first?.toInt(),
            den = a.last?.toInt(){
            return Double(num / den)
        } else {
            return 0.0
        }
    }

    var selectedThickness: String {
        return thicknesses[self.selectedRowInComponent(0)]
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.dataSource = self
        self.delegate = self
    }

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return thicknesses.count
    }

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return thicknesses[row]
    }

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        thicknessChangeHandle!()
    }
}


class BoardFootBackendPickerView: UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    // Drawing code
    }
    */
    private let backends = ["Default", "Dropbox", "iCloud"]

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.dataSource = self
        self.delegate = self
    }

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return backends.count
    }

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return backends[row]
    }

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

    }
}