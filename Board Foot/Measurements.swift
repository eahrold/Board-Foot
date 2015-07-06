//
//  Measurements.swift
//  Board Foot
//
//  Created by Eldon on 8/14/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//

import Foundation

enum DimensionUnit: Double {
    case BFInch = 12.0
    case BFFoot = 1.0
}

class BoardThickness: NSObject, NSSecureCoding  {
    var numerator: Int = 4
    var denominator: Int = 4

    var string: String {
        return "\(self.numerator)/\(self.denominator)"
    }

    var value: Double {
        return Double(self.numerator) / Double(self.denominator)
    }

    init(numerator: Int, denominator: Int){
        self.numerator = numerator
        self.denominator = denominator
    }

    init(str: String){
        let a = str.componentsSeparatedByString("/") as Array;
        if a.count == 2 {
            if let
                n = a.first?.toInt(),
                d = a.last?.toInt()
            {   self.numerator = n
                self.denominator = d
            }
        }
    }

    // Mark: Secure Coding
    required init(coder: NSCoder) {
        self.numerator = coder.decodeIntegerForKey("numerator")
        self.denominator = coder.decodeIntegerForKey("denominator")
    }

    static func supportsSecureCoding() -> Bool {
        return true
    }

    func encodeWithCoder(encoder: NSCoder) {
        [encoder.encodeInteger(self.numerator, forKey: "numerator")]
        [encoder.encodeInteger(self.denominator, forKey: "denominator")]
    }

}

class BoardDimension: NSObject, NSSecureCoding {
    var size = 0.0
    var decorator = DimensionUnit.BFInch
    var string : String {
        var decoratorString:String

        switch decorator {
        case .BFInch:
            decoratorString = "\""
        case .BFFoot:
            decoratorString = "'"
        }

        return "\(Int(round(self.size)))\(decoratorString)"
    }

    var value: Double {
        return self.size / self.decorator.rawValue
    }

    init(size: Double, decorator: DimensionUnit){
        self.size = size
        self.decorator = decorator
    }

    // Mark: Secure Coding
    required init(coder: NSCoder) {
        self.size = coder.decodeDoubleForKey("size")
        if let decorator = DimensionUnit(rawValue: coder.decodeDoubleForKey("decorator")){
            self.decorator = decorator
        }
    }

    static func supportsSecureCoding() -> Bool {
        return true
    }

    func encodeWithCoder(encoder: NSCoder) {
        [encoder.encodeDouble(self.size, forKey: "size")]
        [encoder.encodeDouble(self.decorator.rawValue, forKey: "decorator")]
    }

}

class BoardMeasurement: NSObject, NSSecureCoding {
    var length: BoardDimension!
    var width: BoardDimension!
    var thickness: BoardThickness!

    var string: String {
        return "\(thickness.string) x \(width.string) x \(length.string)"
    }

    var totalSize: Double {
        return length.value * width.value * thickness.value
    }

    init(length: BoardDimension, width: BoardDimension, thickness: BoardThickness){
        self.length = length
        self.width = width
        self.thickness = thickness
    }

    // Mark: Secure Coding
    required init(coder: NSCoder) {
        if let length = coder.decodeObjectOfClass(BoardDimension.self, forKey: "length") as? BoardDimension {
            self.length = length
        }

        if let width = coder.decodeObjectOfClass(BoardDimension.self, forKey: "width") as? BoardDimension {
            self.width = width
        }

        if let thickness = coder.decodeObjectOfClass(BoardThickness.self, forKey: "thickness") as? BoardThickness {
            self.thickness = thickness
        }
    }

    static func supportsSecureCoding() -> Bool {
        return true

    }

    func encodeWithCoder(encoder: NSCoder) {
        [encoder.encodeObject(self.length, forKey: "length")]
        [encoder.encodeObject(self.width, forKey: "width")]
        [encoder.encodeObject(self.thickness, forKey: "thickness")]
    }
}