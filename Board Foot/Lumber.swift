//
//  LumberType.swift
//  Board Foot
//
//  Created by Eldon on 8/14/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//

import Foundation

class Lumber : NSObject, NSSecureCoding {
    var measurement: BoardMeasurement?
    var species: Species?

    init(measurement: BoardMeasurement){
        self.measurement = measurement
    }

    convenience init(measurement: BoardMeasurement, species: Species){
        self.init(measurement: measurement)
        self.species = species
    }

    required init(coder aDecoder: NSCoder) {
        if let measurement = aDecoder.decodeObjectOfClass(BoardMeasurement.self, forKey: "measurement") as? BoardMeasurement {
            self.measurement = measurement
        }
        
        if let species = aDecoder.decodeObjectOfClass(Species.self, forKey: "variety") as? Species {
            self.species = species
        }
    }

    func encodeWithCoder(encoder: NSCoder) {
        encoder.encodeObject(self.species, forKey: "species")
        encoder.encodeObject(self.measurement, forKey: "measurement")
    }

    static func supportsSecureCoding() -> Bool {
        return true
    }

}
