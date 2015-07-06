//
//  ViewController.swift
//  Board Foot
//
//  Created by Eldon on 7/6/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//

import UIKit

class BoardMeasurementViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    var job :Job?

    //MARK: Properties
    @IBOutlet weak var length_textField: UITextField!
    @IBOutlet weak var length_unitControl: UISegmentedControl!

    @IBOutlet weak var measurementNavBar: UINavigationBar!
    @IBOutlet weak var measurementNavTitle: UINavigationItem!

    @IBOutlet weak var thicknessSlider: UISlider!
    @IBOutlet weak var thicknessLabel: UILabel!

    @IBOutlet weak var width_textField: UITextField!
    @IBOutlet weak var width_unitControl: UISegmentedControl!

    @IBOutlet weak var results_textField: UITextField!

    @IBOutlet weak var runningTotal_label: UILabel!

    @IBOutlet weak var tableView: UITableView!

    //MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Delegates
        tableView.dataSource = self
        tableView.delegate = self

        width_textField.delegate = self
        length_textField.delegate = self

        // Length
        length_textField.text = "8";
        length_textField.addTarget(self, action: "recalculate:", forControlEvents: .EditingChanged)
        length_unitControl.addTarget(self, action:"changeUnit:", forControlEvents: .ValueChanged)
        length_unitControl.selectedSegmentIndex = 1; // Feet

        // Width
        width_textField.text = "6";
        width_textField.addTarget(self, action: "recalculate:", forControlEvents: .EditingChanged)

        width_unitControl.addTarget(self, action:"changeUnit:", forControlEvents: .ValueChanged)
        width_unitControl.selectedSegmentIndex = 0; // Inches

        // Thickness
        thicknessSlider.addTarget(self, action: "sliderValueDidChange:", forControlEvents: .ValueChanged )

        if let sliderValue = NSUserDefaults.standardUserDefaults().objectForKey("DefaultThickness") as? NSNumber {
            thicknessSlider.value = sliderValue.floatValue
        }

        if let job = self.job {
            self.measurementNavTitle.title = "Measurements for " + job.name
        }

        reloadAndAdjustTotal()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        recalculate(self);
        return false
    }

    //MARK: IBActions
    @IBAction func changeUnit(sender: UISegmentedControl) {
        if(sender.isEqual(length_unitControl)){
            convertUnitForTextField(sender.selectedSegmentIndex, sender: length_textField)
        } else if (sender.isEqual(width_unitControl)){
            convertUnitForTextField(sender.selectedSegmentIndex, sender: width_textField)
        }

        recalculate(self)
    }

    @IBAction func sliderValueDidChange(sender: UISlider){
        let floatVal = roundf(sender.value)
        sender.value = floatVal
        thicknessLabel.text = "\(Int(floatVal))/4"
        NSUserDefaults.standardUserDefaults().setFloat(floatVal, forKey: "DefaultThickness")
        recalculate(self)
    }

    @IBAction func removeUnit(sender: AnyObject){
        if let x = self.tableView.indexPathForSelectedRow() {
            self.removeUnitAtIndex(x.row);
        }
    }


    @IBAction func addUnitToTable(sender: UIButton) {

        let length = (length_textField.text as NSString).doubleValue
        let lenghtDecorator = self.decoratorFromSegmentControl(length_unitControl)
        let lenghtDimension: BoardDimension = BoardDimension(size: length, decorator: lenghtDecorator)

        let width = (width_textField.text as NSString).doubleValue;
        let widthDecorator = self.decoratorFromSegmentControl(width_unitControl)
        let widthDimension = BoardDimension(size: width, decorator: widthDecorator)

        let thickness = BoardThickness(numerator: Int(thicknessSlider.value), denominator: 4)

        let measurement = BoardMeasurement(length: lenghtDimension, width: widthDimension, thickness: thickness);
        let piece = Lumber(measurement: measurement)

        job?.lumber.append(piece)
        
        reloadAndAdjustTotal()
    }


    func loadJob(job: Job){
        self.job = job
        self.tableView.reloadData()
    }

    func removeUnitAtIndex(idx : Int){
        self.job?.lumber.removeAtIndex(idx)
        reloadAndAdjustTotal()
    }

    // MARK: - Table view data source
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.job?.lumber.count {
            return count
        }
        return 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("unitCell", forIndexPath: indexPath) as! BoardTableViewCell

        if let title = self.job?.lumber[indexPath.row].measurement!.string,
            total = self.job?.lumber[indexPath.row].measurement!.totalSize {
                cell.textLabel?.text = title
                cell.totalText?.text =  String(format: "%.2f", total)
        }

        return cell
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }

    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {

        var deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            self.removeUnitAtIndex(indexPath.row);
        })
        return [deleteAction]
    }

    @IBAction func updateValueWithDrag(sender: AnyObject, forEvent event: UIEvent) {
    }

    @IBAction func recalculate(sender: AnyObject) {
        let thickness = Double(thicknessSlider.value) / 4.0

        let length = calculateSize(length_textField, segment: length_unitControl)
        let width = calculateSize(width_textField, segment: width_unitControl)

        let results = thickness * length * width
        results_textField.text = NSString(format: "%.2f", results) as String;
    }


    func reloadAndAdjustTotal() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if let sum = self.job?.total {
                self.runningTotal_label.text = NSString(format: "%.2f", sum) as String
                self.tableView.reloadData()
            }
        })
    }

    /*
     * This takes the text field and modifies the value based
     * on the selected tag of the UISegment control.
     */
    private func convertUnitForTextField(unit: Int, sender: UITextField) {
        if var senderInt = sender.text.toInt(){
            if(unit == 0) {
                senderInt = senderInt * 12
                // Convert from inches to feet ...
            } else {
                // Convert from feet to inches ...
                senderInt = senderInt / 12
            }

            if senderInt == 0 { senderInt = 1}
            sender.text = String(stringInterpolationSegment: senderInt)
        }
    }

    // Convert the segment control tag into a cooresponding BoardDimensionDecorator
    private func decoratorFromSegmentControl(sender: UISegmentedControl ) -> DimensionUnit {
        if sender.selectedSegmentIndex == 0 {
            return .BFInch
        } else if sender.selectedSegmentIndex == 1 {
            return .BFFoot
        }

        // Fall back
        return .BFInch
    }

    /**
    Get the float value of the size based on the textfield's values & the selected index of 
    a segmented control

    :param: textField the text field with value to compute
    :param: segment   the segmented control for the size index

    :returns: calculated float value based on text field and segment control.
    */
    private func calculateSize(textField: UITextField, segment: UISegmentedControl) -> Double {
        let size = (textField.text as NSString).doubleValue

        if(segment.selectedSegmentIndex == 0){
            return size / 12.0
        } else {
            return size
        }
    }


}

