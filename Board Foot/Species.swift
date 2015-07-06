//
//  Species.swift
//  Board Foot
//
//  Created by Eldon on 8/17/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//

import Foundation

class Species: NSObject, NSSecureCoding {
    // TODO: if http://www.wood-database.com provides an API or is willing to
    // provided us with XML data, implement that.

    override init() {
        self.json = [String: AnyObject]()
    }

    var scientificName = ""
    var cost = 0.00
    let json: [String: AnyObject]

    func speciesNames() -> [String] {
        return ["names", "two"]
    }

    private func speciesQuery(key: String) -> AnyObject? {
        // TODO: Hook this up to some DB
        if let dict = self.json[self.scientificName] as? [String: AnyObject],
            results: AnyObject = dict[key] as AnyObject? {
                return results
        }
        return nil
    }

    var commonName: String {
        if let results = speciesQuery("commonName") as? String {
            return results
        } else {
            return ""
        }
    }

    var specificGravity: Double {
        if let n = speciesQuery("specificGravity") as? NSNumber {
            return n.doubleValue
        } else {
            return 0
        }
    }

    var jankaHardness: Double {  // lbf/in2
        if let n = speciesQuery("jankaHardness") as? NSNumber {
            return n.doubleValue
        } else {
            return 0
        }
    }

    var modlusOfRupture: Double { // lbf/in
        if let n = speciesQuery("modlusOfRupture") as? NSNumber {
            return n.doubleValue
        } else {
            return 0
        }
    }

    var crushingStrenght: Double { // lbf/in2
        if let n = speciesQuery("crushingStrenght") as? NSNumber {
            return n.doubleValue
        } else {
            return 0
        }
    }

    required convenience init(coder aDecoder: NSCoder) {
        self.init()
        if let scientificName = aDecoder.decodeObjectOfClass(NSString.self, forKey: "scientificName") as? String {
            self.scientificName = scientificName
        }
        self.cost = aDecoder.decodeDoubleForKey("cost")
    }

    func encodeWithCoder(encoder: NSCoder) {
        encoder.encodeObject(self.scientificName, forKey: "scientificName")
        encoder.encodeDouble(self.cost, forKey: "cost")
    }

    static func supportsSecureCoding() -> Bool {
        return true
    }
    
}
