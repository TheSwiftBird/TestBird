//
//  NetworkingServiceStub.swift
//  TestBirdTests
//
//  Created by Yakov Manshin on 7/11/24.
//

@testable import TestBirdApp

import Foundation

class NetworkingServiceStub: NetworkingServiceProtocol {
    
    var executeDataRequest_invocationCount = 0
    var executeDataRequest_requests = [URLRequest]()
    var executeDataRequest_result: Result<Data, any Error>!
    
    func executeDataRequest(_ request: URLRequest) async throws -> Data {
        executeDataRequest_invocationCount += 1
        executeDataRequest_requests.append(request)
        
        switch executeDataRequest_result! {
        case .success(let data): return data
        case .failure(let error): throw error
        }
    }
    
}
