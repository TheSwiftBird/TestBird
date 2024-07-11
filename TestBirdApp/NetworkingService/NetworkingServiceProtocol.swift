//
//  NetworkingServiceProtocol.swift
//  TestBirdApp
//
//  Created by Yakov Manshin on 7/10/24.
//

import Foundation

protocol NetworkingServiceProtocol {
    
    func executeDataRequest(_ request: URLRequest) async throws -> Data
    
}
