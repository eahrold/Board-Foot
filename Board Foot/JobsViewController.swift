//
//  FirstViewController.swift
//  BoardFoot2
//
//  Created by Eldon on 7/31/15.
//  Copyright (c) 2015 EEAapps. All rights reserved.
//

import UIKit

class JobsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var allJobs = [Job]()
    var jobs: [Job] {
        let filteredArray = allJobs.filter() {
            return ($0.completed == false)
        }
        return filteredArray
    }

    var tableView : UITableView?

    override func viewDidLoad() {
        super.viewDidLoad()

        Job.getJobs { (arr) -> Void in
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                if let jar = arr as? [Job] {
                    self.allJobs = jar
                }
                self.tableView?.reloadData()
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {
    }

    // MARK: Segues
    @IBAction func saveJob(unwindSegue: UIStoryboardSegue){
        if let source = unwindSegue.sourceViewController as? BoardMeasurementViewController,
            job = source.job
        {
            job.save()
            if contains(self.allJobs, job) == false {
                self.allJobs.append(job)
            }
            
            // TODO: Reload just the single row.
            self.tableView?.reloadData()
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let cell = sender as? UITableViewCell,
            idxPath = tableView?.indexPathForCell(cell),
            measurementController = segue.destinationViewController as? BoardMeasurementViewController {
                measurementController.job = self.jobs[idxPath.row]
        }
    }

    // MARK: New Jobs
    @IBAction func AddNewJob(sender: UIButton) {
        let job = Job()

        self.promptForName(job, completion: { () -> Void in
            if count(job.name) > 0 {
                self.allJobs.append(job)
                self.tableView?.reloadData()
            }
        })
    }

    func promptForName(job: Job, completion: (() -> Void)?){
        var alert = UIAlertController(title: "Create a new job", message:"", preferredStyle: UIAlertControllerStyle.Alert)

        alert.addAction(UIAlertAction(title: "Save", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction!) -> Void in
            if let name = alert.textFields?.first as? UITextField {
                if (name.text.isEmpty == false){
                    job.name = name.text
                }
            }
            completion!()
        }))

        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            if job.name.isEmpty {
                textField.placeholder = "Enter a name for the new job"
            } else {
                textField.text = job.name
            }
        })


        self.presentViewController(alert, animated: true, completion: { () -> Void in
            //
        });
    }

    // MARK: Table View Data Source & Delegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        self.tableView = tableView;
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return self.jobs.count
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }

    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
    }

    // MARK: Table Dragging
    @IBAction func updateValueWithDrag(sender: AnyObject, forEvent event: UIEvent) {
    }

    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        var deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            if self.jobs.count > indexPath.row {
                let job = self.jobs[indexPath.row]
                job.remove()
                if let idx = find(self.allJobs, job){
                    self.allJobs.removeAtIndex(idx)
                }
                tableView.reloadData()
            }
        })
        return [deleteAction]
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("jobCell", forIndexPath: indexPath) as! BoardFootJobTableViewCell
        let job = jobs[indexPath.row]

        cell.textLabel?.text = job.name
        cell.totalButton.setTitle("Total: \(job.total)", forState: .Normal)

        return cell
    }
}

