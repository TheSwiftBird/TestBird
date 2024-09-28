//
//  HatchDateFormatterTests.swift
//  TestBirdTests
//
//  Created by Yakov Manshin on 7/11/24.
//

@testable import TestBirdApp

import Foundation
import Testing

// This is a test suite, even though it’s not marked as such.
struct HatchDateFormatterTests {
    
    // Gone are variables and force-unwrapping!
    // Suite instances aren’t reused, so each test method will have its own `formatter`.
    private let formatter = HatchDateFormatter()
    
    // `setUp()` and `tearDown()` aren’t needed too!
    
    // Tags help you organize tests:
    @Test(.tags(.required, .AppScreen.home))
    func daysElapsed_hatchDateInFuture() {
        let hatchDate = Date(timeIntervalSince1970: 10_000_000)
        let referenceDate = Date(timeIntervalSince1970: 5_000_000)
        
        // `#expect` makes sure the *specific* error is thrown.
        // If there’s a different error or no error at all, the test will fail automatically.
        #expect(throws: HatchDateFormatter.Error.hatchDateIsInFuture) {
            try formatter.daysElapsed(between: hatchDate, and: referenceDate)
        }
    }
    
    // Parameterized testing lets you pass many parameters to a single test.
    // The organizer and reports will show the parameters as if they were separate tests.
    @Test(arguments: [
        (10_000_000, 10_604_800, "7 days"),
        (10_000_000_000, 10_031_536_000, "365 days"),
        (10_000_000_000, 10_315_360_000, "3,650 days"),
    ])
    func daysElapsed(hatchTimestamp: TimeInterval, referenceTimestamp: TimeInterval, expectedResult: String) throws {
        let hatchDate = Date(timeIntervalSince1970: hatchTimestamp)
        let referenceDate = Date(timeIntervalSince1970: referenceTimestamp)
        
        #expect(try formatter.daysElapsed(between: hatchDate, and: referenceDate) == expectedResult)
    }
    
}
