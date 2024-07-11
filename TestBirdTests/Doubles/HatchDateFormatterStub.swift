//
//  HatchDateFormatterStub.swift
//  TestBirdTests
//
//  Created by Yakov Manshin on 7/11/24.
//

@testable import TestBirdApp

import Foundation

class HatchDateFormatterStub: HatchDateFormatterProtocol {
    
    var relativeHatchDate_invocationCount = 0
    var relativeHatchDate_timestamps = [TimeInterval]()
    var relativeHatchDate_result: Result<String, any Error>!
    
    func relativeHatchDate(from timestamp: TimeInterval) throws -> String {
        relativeHatchDate_invocationCount += 1
        relativeHatchDate_timestamps.append(timestamp)
        
        switch relativeHatchDate_result! {
        case .success(let string): return string
        case .failure(let error): throw error
        }
    }
}
