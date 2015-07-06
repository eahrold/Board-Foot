//
//  Job.swift
//  
//
//  Created by Eldon on 7/7/15.
//
//

import UIKit
import CloudKit

class Job: NSObject, NSSecureCoding {

    // MARK: Properties
    var lumber = [Lumber]()
    var name: String
    var creationDate: NSDate
    var uuid: CKRecordID

    private let formatter = NSDateFormatter()

    // MARK: -- Computed --
    var dateString: String {
        return self.formatter.stringFromDate(creationDate)
    }

    var jobDescription: String {
        return "Job: \(name) Total: \(self.total)"
    }

    // MARK: initializers

    override init() {
        self.name = ""
        self.formatter.dateStyle = NSDateFormatterStyle.LongStyle
        self.formatter.timeStyle = .MediumStyle
        self.creationDate = NSDate()
        self.uuid = CKRecordID(recordName: "\(self.creationDate)")
    }

    convenience init(name : String){
        self.init()
        self.name = name
    }

    // MARK: Functions
    func save(){
        Logger(.Debug, "Saving \(self)")
        Job.currentBackend()?.save(self)
    }

    func remove(){
        Logger(.Debug, "Removing \(self)")
        Job.currentBackend()?.remove(self)
    }

    var total: Double {
        var sum = 0.0
        for piece in lumber {
            sum += piece.measurement!.totalSize
        }
        return sum
    }

    func totalBySpecies(scientificName: String) -> Double {
        var sum = 0.0
        for piece in lumber {
            if piece.species?.scientificName == scientificName {
                sum += piece.measurement!.totalSize
            }
        }
        return sum
    }

    // MARK: Secure coding
    required convenience init(coder: NSCoder) {
        self.init()
        if let name = coder.decodeObjectOfClass(NSString.self, forKey:"name") as? String {
            self.name = name
        }

        if let creationDate = coder.decodeObjectOfClass(NSDate.self, forKey:"date") as? NSDate {
            self.creationDate = creationDate
        }

        if let uuid = coder.decodeObjectOfClass(CKRecordID.self, forKey:"uuid") as? CKRecordID {
            self.uuid = uuid
        }

        let set = Set(arrayLiteral: [ NSArray.self, Lumber.self ])
        if let lumber = coder.decodeObjectOfClasses(set, forKey:"lumber") as? [Lumber] {
            self.lumber = lumber
        }
    }

    func encodeWithCoder(encoder: NSCoder) {
        encoder.encodeObject(self.name, forKey: "name")
        encoder.encodeObject(self.creationDate, forKey: "creationDate")
        encoder.encodeObject(self.uuid, forKey: "uuid")
        encoder.encodeObject(self.lumber, forKey: "lumber")
    }

    static func supportsSecureCoding() -> Bool {
        return true
    }

    // MARK: Class Functions
    class private func currentBackend() -> Backend? {
        let defaults = NSUserDefaults()
        var backend: Backend
        if let backendDescription = defaults.objectForKey("CurrentBackend") as? String {
            switch backendDescription {
            case "DropBox":
                backend = DropBox()
            case "CoreData":
                backend = CoreData()
            case "CloudKit":
                backend = CloudKit()
            default:
                backend = Defaults()
            }
        } else {
            backend = Defaults()
        }

        Logger(.Debug, "UsingBackend \(backend.self)")
        return backend
    }

    class func getJobs(completion: (NSArray) -> Void){
        let j = self.currentBackend()!.load()
        completion(j)
    }
}
