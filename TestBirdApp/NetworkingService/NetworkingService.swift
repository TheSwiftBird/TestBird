//
//  NetworkingService.swift
//  TestBirdApp
//
//  Created by Yakov Manshin on 7/10/24.
//

import Foundation

class NetworkingService: NetworkingServiceProtocol {
    
    func executeDataRequest(_ request: URLRequest) async throws -> Data {
        // TODO: Implement
        """
        {
            "name": "PieTheMagpie",
            "hatchTimestamp": 1710676800
        }
        """.data(using: .utf8)!
    }
    
}
