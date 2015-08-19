//
//  Backends.swift
//  Board Foot
//
//  Created by Eldon on 8/14/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

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
    
    :returns: true on success, otherwise false
    */
    func save(job: Job) -> Bool

    /**
    Delete a Job from persistance storage

    :param: job Job object to remove
    
    :returns: true on success, otherwise false
    */
    func remove(job: Job) -> Bool

    /**
    Remove all of the jobs from the backend storage

    :returns: true on success, otherwise false
    */
    func removeAll() -> Bool

}


/// NSUserDefaults Backend for Board Foot
class Defaults:  NSObject, Backend {

    let jobsKey = "Jobs"

    private var jobsData: [NSData]? {
        let dataArray = NSUserDefaults.standardUserDefaults().objectForKey(jobsKey) as? [NSData]
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

        NSUserDefaults.standardUserDefaults().setObject(self.archiveJobArray(jobs), forKey: jobsKey)
        return true
    }

    func remove(job: Job) -> Bool {
        var jobs = self.jobsArray
        for (idx, j) in enumerate(jobs) {
            let r1 = j.uuid
            let r2 = job.uuid

            if r1 == r2 {
                jobs.removeAtIndex(idx)
                break
            }
        }
        NSUserDefaults.standardUserDefaults().setObject(self.archiveJobArray(jobs), forKey: jobsKey)
        return true
    }

    func removeAll() -> Bool {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(jobsKey)
        return true
    }
}

/// CoreData Backend for Board Foot
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

    func removeAll() -> Bool {
        return true
    }
}

/// DropBox backend for Board Foot
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

    func removeAll() -> Bool {
        return true
    }
}

/// CloudKit backend for Board Foot
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

    func removeAll() -> Bool {
        return true
    }
}
