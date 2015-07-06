//
//  Logger.swift
//  Board Foot
//
//  Created by Eldon on 8/16/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//

import Foundation

enum LogLevel: Int {
    case Alert = 0
    case Verbose = 1
    case Debug = 2
}

func Logger(level: LogLevel, message: String){
    let logLevel = NSUserDefaults.standardUserDefaults().integerForKey("LogLevel")
    if level.rawValue <= logLevel {
        NSLog("[%@] %@", message)
    }
}