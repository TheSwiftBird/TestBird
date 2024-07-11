//
//  HatchDateFormatterProtocol.swift
//  TestBirdApp
//
//  Created by Yakov Manshin on 7/10/24.
//

import Foundation

protocol HatchDateFormatterProtocol {
    
    func relativeHatchDate(from timestamp: TimeInterval) throws -> String
    
}
