//
//  UserManagerTests.swift
//  TestBirdTests
//
//  Created by Yakov Manshin on 7/11/24.
//

@testable import TestBirdApp

import Foundation
import Testing

// `@Suite` lets you customize many things:
@Suite(
    "UserManager Tests",
    .timeLimit(.minutes(1)),
    .enabled(if: true, "Suites (and individual tests) can be enabled and disabled conditionally")
) struct UserManagerTests {
    
    // When you can’t initialize suite dependencies inline, use a normal initializer (below).
    private let manager: UserManager
    
    private let networkingService: NetworkingServiceStub
    private let hatchDateFormatter: HatchDateFormatterStub
    
    init() {
        networkingService = NetworkingServiceStub()
        hatchDateFormatter = HatchDateFormatterStub()
        manager = UserManager(networkingService: networkingService, dateFormatter: hatchDateFormatter)
    }
    
    @Test(.tags(.required)) func infoForUser_validInfo() async {
        networkingService.executeDataRequest_result = .success(Utilities.validData)
        hatchDateFormatter.relativeHatchDate_result = .success("TEST days")
        
        let info = await manager.infoForUser(withID: 101)
        
        #expect(info == "TEST Name (ID 101) hatched TEST days ago")
        #expect(networkingService.executeDataRequest_invocationCount == 1)
        
        #expect(
            networkingService.executeDataRequest_requests[0].url?.absoluteString
            == "https://example.com/user_data?id=101"
        )
        #expect(hatchDateFormatter.relativeHatchDate_invocationCount == 1)
        #expect(hatchDateFormatter.relativeHatchDate_timestamps[0] == 12345)
    }
    
    @Test func infoForUser_networkingError() async {
        networkingService.executeDataRequest_result = .failure(Utilities.Error.networking)
        
        let info = await manager.infoForUser(withID: 343)
        
        #expect(info.starts(with: "Cannot get info for the user with ID 343"))
        #expect(hatchDateFormatter.relativeHatchDate_invocationCount == 0)
    }
    
    @Test func _infoForUser_validInfo() async throws {
        networkingService.executeDataRequest_result = .success(Utilities.validData)
        hatchDateFormatter.relativeHatchDate_result = .success("TEST days")
        
        let info = try await manager._infoForUser(withID: 123)
        
        #expect(info == "TEST Name (ID 123) hatched TEST days ago")
        #expect(networkingService.executeDataRequest_invocationCount == 1)
        #expect(
            networkingService.executeDataRequest_requests[0].url?.absoluteString
            == "https://example.com/user_data?id=123"
        )
        #expect(hatchDateFormatter.relativeHatchDate_invocationCount == 1)
        #expect(hatchDateFormatter.relativeHatchDate_timestamps[0] == 12345)
    }
    
    @Test func _infoForUser_networkingError() async {
        networkingService.executeDataRequest_result = .failure(Utilities.Error.networking)
        hatchDateFormatter.relativeHatchDate_result = .success("TEST days")
        
        await #expect(throws: Utilities.Error.networking) {
            _ = try await manager._infoForUser(withID: 789)
        }
        
        #expect(networkingService.executeDataRequest_invocationCount == 1)
        #expect(
            networkingService.executeDataRequest_requests[0].url?.absoluteString
            == "https://example.com/user_data?id=789"
        )
        #expect(hatchDateFormatter.relativeHatchDate_invocationCount == 0)
    }
    
    @Test(.bug(
        "https://github.com/swiftlang/swift-testing/issues/738",
        "Unexpected build errors with guard-case expressions")
    )
    func _infoForUser_decodingError() async throws {
        networkingService.executeDataRequest_result = .success(Utilities.invalidData)
        hatchDateFormatter.relativeHatchDate_result = .success("TEST days")
        
        await #expect {
            _ = try await manager._infoForUser(withID: 789)
        } throws: { error in
            // Strangely, this compiles:
            guard case .keyNotFound(let key, _) = error as? DecodingError else { return false }
            
            // But this doesn’t (“Command SwiftCompile failed with a nonzero exit code”):
            // guard case DecodingError.keyNotFound(let key, _) = error else { return false }
            
            return key.stringValue == "hatchTimestamp"
        }
        
        #expect(networkingService.executeDataRequest_invocationCount == 1)
        #expect(
            networkingService.executeDataRequest_requests[0].url?.absoluteString
            == "https://example.com/user_data?id=789"
        )
        #expect(hatchDateFormatter.relativeHatchDate_invocationCount == 0)
    }
    
    @Test func _infoForUser_formattingError() async {
        networkingService.executeDataRequest_result = .success(Utilities.validData)
        hatchDateFormatter.relativeHatchDate_result = .failure(Utilities.Error.formatting)
        
        await #expect(throws: Utilities.Error.formatting) {
            _ = try await manager._infoForUser(withID: 789)
        }
        
        #expect(networkingService.executeDataRequest_invocationCount == 1)
        #expect(
            networkingService.executeDataRequest_requests[0].url?.absoluteString
            == "https://example.com/user_data?id=789"
        )
        #expect(hatchDateFormatter.relativeHatchDate_invocationCount == 1)
        #expect(hatchDateFormatter.relativeHatchDate_timestamps[0] == 12345)
    }
    
    @Test func userData_someData() async throws {
        networkingService.executeDataRequest_result = .success(Data([1, 2, 3]))
        
        let data = try await manager.userData(id: 999)
        
        #expect(networkingService.executeDataRequest_invocationCount == 1)
        #expect(
            networkingService.executeDataRequest_requests[0].url?.absoluteString
            == "https://example.com/user_data?id=999"
        )
        #expect(data == Data([1, 2, 3]))
    }
    
    @Test func userData_noData() async {
        networkingService.executeDataRequest_result = .failure(NSError(domain: "TEST", code: 456))
        
        await #expect {
            _ = try await manager.userData(id: 777)
        } throws: {
            let error = $0 as NSError
            return error.domain == "TEST" && error.code == 456
        }
        #expect(networkingService.executeDataRequest_invocationCount == 1)
        #expect(
            networkingService.executeDataRequest_requests[0].url?.absoluteString
            == "https://example.com/user_data?id=777"
        )
    }
    
    @Test func userFromData_validData() throws {
        let data = """
        {
            "name": "TEST Name",
            "hatchTimestamp": 12345
        }
        """.data(using: .utf8)!
        
        let user = try manager.userFromData(data)
        
        let expectedUser = BirdUser(name: "TEST Name", hatchTimestamp: 12345)
        #expect(user == expectedUser)
    }
    
    @Test func userFromData_invalidData() {
        let data = """
        {
            "name": "TEST Name",
            "hatch_timestamp": 12345
        }
        """.data(using: .utf8)!
        
        #expect(throws: DecodingError.self) {
            try manager.userFromData(data)
        }
    }
    
}

fileprivate enum Utilities {
    
    static let validData = """
        {
            "name": "TEST Name",
            "hatchTimestamp": 12345
        }
        """.data(using: .utf8)!
    
    static let invalidData = """
        {
            "name": "TEST Name",
            "hatch_timestamp": 12345
        }
        """.data(using: .utf8)!
    
    enum Error: Swift.Error {
        case networking
        case formatting
    }
    
}
