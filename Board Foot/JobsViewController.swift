//
//  FirstViewController.swift
//  BoardFoot2
//
//  Created by Eldon on 7/31/15.
//  Copyright (c) 2015 EEAapps. All rights reserved.
//

import UIKit
import CloudKit

class JobsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var jobs = [Job]()
    var tableView : UITableView?

    override func viewDidLoad() {
        super.viewDidLoad()

        Job.getJobs { (arr) -> Void in
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                if let jar = arr as? [Job] {
                    self.jobs = jar
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
    @IBAction func unwindMeasurementController(unwindSegue: UIStoryboardSegue){
        if let source = unwindSegue.sourceViewController as? BoardMeasurementViewController,
            job = source.job
        {
                job.save()
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
                self.jobs.append(job)
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
        return jobs.count
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("jobCell", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = jobs[indexPath.row].jobDescription
        return cell
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

                self.jobs.removeAtIndex(indexPath.row)
                tableView.reloadData()
            }
        })

        var modifyAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Change Name" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
                let job = self.jobs[indexPath.row]
               self.promptForName(job, completion: { () -> Void in
                    job.save()
                    self.tableView?.reloadData()
               });
        })

        modifyAction.backgroundColor = UIColor.blueColor()
        return [deleteAction, modifyAction]
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("did drag...")
    };

    
    var startLocation: CGPoint?
    func swipeLeft(sender: UIGestureRecognizer) {
        let threshold: CGFloat = 100

        if (sender.state == .Began){
            startLocation = sender.locationInView(self.view)
        } else if (sender.state == .Ended) {
            if let start = self.startLocation {
                let stopLocation = sender.locationInView(self.view)
                let dx = stopLocation.x - start.x
                let dy = stopLocation.y - start.y
                let distance = sqrt(dx*dx + dy*dy );

                if (distance > threshold )
                {
                    println("DELETE_ROW");
                }
            }
        }
    }

}

