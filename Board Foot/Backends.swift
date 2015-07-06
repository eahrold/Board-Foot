//
//  Backends.swift
//  Board Foot
//
//  Created by Eldon on 8/14/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//

import Foundation
import CoreData

/**
*  Back end Protocol that all backends should conform to.
*/
protocol Backend {
    /**
    Get an array of jobs out of the backend

    :returns: Array of Jobs
    */
    func load() -> [Job]

    /**
    Save or Update a Job

    :param: job Job object to be saved or updated
    */
    func save(job: Job) -> Bool

    /**
    Delete a Job from persistance storage

    :param: job Job object to remove
    */
    func remove(job: Job) -> Bool
}


/// NSUserDefaults Backend
class Defaults:  NSObject, Backend {

    private var jobsData: [NSData]? {
        let dataArray = NSUserDefaults.standardUserDefaults().objectForKey("Jobs") as? [NSData]
        return dataArray
    }

    private var jobsArray: [Job] {
        var array = [Job]()
        if let dataArray = self.jobsData {
            for data in dataArray {
                if let job = self.unarchive(data) as? Job {
                    array.append(job)
                }
            }
        }
        return array
    }

    private func archive(object: Job) -> NSData? {
        let archive: NSData? = NSKeyedArchiver.archivedDataWithRootObject(object);
        return archive
    }

    private func archiveJobArray(array: [Job]) -> [NSData] {
        var dataArray = [NSData]()
        for job in array {
            dataArray.append(self.archive(job)!)
        }
        return dataArray
    }

    private func unarchive(data: NSData) -> AnyObject? {
        let unarchive = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? Job
        return unarchive
    }

    // MARK: -- Defaults Backend Protocol --
    func load() -> [Job] {
        return self.jobsArray
    }

    func save(job: Job) -> Bool {
        var jobs = self.jobsArray
        var updated = false
        for (idx, j) in enumerate(jobs) {
            if j.uuid == job.uuid {
                jobs[idx] = job
                updated = true
                break
            }
        }

        if updated == false {
            jobs.append(job)
        }

        NSUserDefaults.standardUserDefaults().setObject(self.archiveJobArray(jobs), forKey: "Jobs")
        return true
    }

    func remove(job: Job) -> Bool {
        var jobs = self.jobsArray
        for (idx, j) in enumerate(jobs) {
            let r1 = j.uuid.recordName
            let r2 = job.uuid.recordName

            if r1 == r2 {
                jobs.removeAtIndex(idx)
                break
            }
        }
        NSUserDefaults.standardUserDefaults().setObject(self.archiveJobArray(jobs), forKey: "Jobs")
        return true
    }
}

/// CoreData Backend
class CoreData:  NSManagedObject, Backend {
    // MARK: -- Core Data Backend Protocol --
    func load() -> [Job] {
        return []
    }

    func save(job: Job) -> Bool {
        return true
    }

    func remove(job: Job) -> Bool {
        return true
    }
}

/// DropBox backend
class DropBox: NSObject, Backend {
    // MARK: -- DropBox Backend Protocol --

    func load() -> [Job] {
        return []
    }

    func save(job: Job) -> Bool {
        return true
    }

    func remove(job: Job) -> Bool {
        return true
    }
}

/// CloudKit backend
class CloudKit:  NSObject, Backend {
    // MARK: -- CloudKit Backend Protocol --
    func load() -> [Job] {
        return []
    }

    func save(job: Job) -> Bool {
        return true
    }

    func remove(job: Job) -> Bool {
        return true
    }
}