//
//  HatchDateFormatterTests.swift
//  TestBirdTests
//
//  Created by Yakov Manshin on 7/11/24.
//

@testable import TestBirdApp

import XCTest

final class HatchDateFormatterTests: XCTestCase {
    
    private var formatter: HatchDateFormatter!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        formatter = HatchDateFormatter()
    }
    
    func test_daysElapsed_hatchDateInFuture() {
        let hatchDate = Date(timeIntervalSince1970: 10_000_000)
        let referenceDate = Date(timeIntervalSince1970: 5_000_000)
        
        do {
            let _ = try formatter.daysElapsed(between: hatchDate, and: referenceDate)
            XCTFail()
        } catch HatchDateFormatter.Error.hatchDateIsInFuture { } catch {
            XCTFail()
        }
    }
    
    func test_daysElapsed_oneWeek() throws {
        let hatchDate = Date(timeIntervalSince1970: 10_000_000)
        let referenceDate = Date(timeIntervalSince1970: 10_604_800)
        
        let daysElapsed = try formatter.daysElapsed(between: hatchDate, and: referenceDate)
        
        XCTAssertEqual(daysElapsed, "7 days")
    }
    
    func test_daysElapsed_oneYear() throws {
        let hatchDate = Date(timeIntervalSince1970: 10_000_000_000)
        let referenceDate = Date(timeIntervalSince1970: 10_031_536_000)
        
        let daysElapsed = try formatter.daysElapsed(between: hatchDate, and: referenceDate)
        
        XCTAssertEqual(daysElapsed, "365 days")
    }
    
    func test_daysElapsed_tenYears() throws {
        let hatchDate = Date(timeIntervalSince1970: 10_000_000_000)
        let referenceDate = Date(timeIntervalSince1970: 10_315_360_000)
        
        let daysElapsed = try formatter.daysElapsed(between: hatchDate, and: referenceDate)
        
        XCTAssertEqual(daysElapsed, "3,650 days")
    }
    
}
