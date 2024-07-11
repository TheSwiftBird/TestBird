//
//  HatchDateFormatter.swift
//  TestBirdApp
//
//  Created by Yakov Manshin on 7/10/24.
//

import Foundation

class HatchDateFormatter: HatchDateFormatterProtocol {
    
    private lazy var dateComponentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day]
        formatter.unitsStyle = .full
        return formatter
    }()
    
    func relativeHatchDate(from timestamp: TimeInterval) throws -> String {
        let hatchDate = Date(timeIntervalSince1970: timestamp)
        let currentDate = Date()
        
        return try daysElapsed(between: hatchDate, and: currentDate)
    }
    
    private func daysElapsed(between hatchDate: Date, and referenceDate: Date) throws -> String {
        guard referenceDate <= hatchDate else {
            throw Error.hatchDateIsInFuture
        }
        
        guard let relativeDate = dateComponentsFormatter.string(from: referenceDate, to: hatchDate) else {
            throw Error.cannotFormatDateComponents
        }
        
        return relativeDate
    }
    
}

extension HatchDateFormatter {
    
    enum Error: Swift.Error {
        case hatchDateIsInFuture
        case cannotFormatDateComponents
    }
    
}
