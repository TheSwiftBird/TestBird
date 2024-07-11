//
//  UserManagerTests.swift
//  TestBirdTests
//
//  Created by Yakov Manshin on 7/11/24.
//

@testable import TestBirdApp

import XCTest

final class UserManagerTests: XCTestCase {
    
    private var manager: UserManager!
    
    private var networkingService: NetworkingServiceStub!
    private var hatchDateFormatter: HatchDateFormatterStub!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        networkingService = NetworkingServiceStub()
        hatchDateFormatter = HatchDateFormatterStub()
        manager = UserManager(networkingService: networkingService, dateFormatter: hatchDateFormatter)
    }
    
    func test_infoForUser_validInfo() async {
        networkingService.executeDataRequest_result = .success(Utilities.validData)
        hatchDateFormatter.relativeHatchDate_result = .success("TEST days")
        
        let info = await manager.infoForUser(withID: 101)
        
        XCTAssertEqual(info, "TEST Name (ID 101) hatched TEST days ago")
        XCTAssertEqual(networkingService.executeDataRequest_invocationCount, 1)
        XCTAssertEqual(
            networkingService.executeDataRequest_requests[0].url?.absoluteString,
            "https://example.com/user_data?id=101"
        )
        XCTAssertEqual(hatchDateFormatter.relativeHatchDate_invocationCount, 1)
        XCTAssertEqual(hatchDateFormatter.relativeHatchDate_timestamps[0], 12345)
    }
    
    func test_infoForUser_networkingError() async {
        networkingService.executeDataRequest_result = .failure(Utilities.Error.networking)
        
        let info = await manager.infoForUser(withID: 343)
        
        XCTAssertTrue(info.starts(with: "Cannot get info for the user with ID 343"))
        XCTAssertEqual(hatchDateFormatter.relativeHatchDate_invocationCount, 0)
    }
    
    func test__infoForUser_validInfo() async throws {
        networkingService.executeDataRequest_result = .success(Utilities.validData)
        hatchDateFormatter.relativeHatchDate_result = .success("TEST days")
        
        let info = try await manager._infoForUser(withID: 123)
        
        XCTAssertEqual(info, "TEST Name (ID 123) hatched TEST days ago")
        XCTAssertEqual(networkingService.executeDataRequest_invocationCount, 1)
        XCTAssertEqual(
            networkingService.executeDataRequest_requests[0].url?.absoluteString, 
            "https://example.com/user_data?id=123"
        )
        XCTAssertEqual(hatchDateFormatter.relativeHatchDate_invocationCount, 1)
        XCTAssertEqual(hatchDateFormatter.relativeHatchDate_timestamps[0], 12345)
    }
    
    func test__infoForUser_networkingError() async {
        networkingService.executeDataRequest_result = .failure(Utilities.Error.networking)
        hatchDateFormatter.relativeHatchDate_result = .success("TEST days")
        
        do {
            let _ = try await manager._infoForUser(withID: 789)
            XCTFail()
        } catch Utilities.Error.networking { 
            XCTAssertEqual(networkingService.executeDataRequest_invocationCount, 1)
            XCTAssertEqual(
                networkingService.executeDataRequest_requests[0].url?.absoluteString,
                "https://example.com/user_data?id=789"
            )
            XCTAssertEqual(hatchDateFormatter.relativeHatchDate_invocationCount, 0)
//            XCTAssertTrue(hatchDateFormatter.relativeHatchDate_timestamps.isEmpty)
        } catch {
            XCTFail()
        }
    }
    
    func test__infoForUser_decodingError() async {
        networkingService.executeDataRequest_result = .success(Utilities.invalidData)
        hatchDateFormatter.relativeHatchDate_result = .success("TEST days")
        
        do {
            let _ = try await manager._infoForUser(withID: 789)
            XCTFail()
        } catch {
            guard case DecodingError.keyNotFound(let key, _) = error else {
                return XCTFail()
            }
            XCTAssertEqual(key.stringValue, "hatchTimestamp")
            
            XCTAssertEqual(networkingService.executeDataRequest_invocationCount, 1)
            XCTAssertEqual(
                networkingService.executeDataRequest_requests[0].url?.absoluteString,
                "https://example.com/user_data?id=789"
            )
            XCTAssertEqual(hatchDateFormatter.relativeHatchDate_invocationCount, 0)
        }
    }
    
    func test__infoForUser_formattingError() async {
        networkingService.executeDataRequest_result = .success(Utilities.validData)
        hatchDateFormatter.relativeHatchDate_result = .failure(Utilities.Error.formatting)
        
        do {
            let _ = try await manager._infoForUser(withID: 789)
            XCTFail()
        } catch Utilities.Error.formatting {
            XCTAssertEqual(networkingService.executeDataRequest_invocationCount, 1)
            XCTAssertEqual(
                networkingService.executeDataRequest_requests[0].url?.absoluteString,
                "https://example.com/user_data?id=789"
            )
            XCTAssertEqual(hatchDateFormatter.relativeHatchDate_invocationCount, 1)
            XCTAssertEqual(hatchDateFormatter.relativeHatchDate_timestamps[0], 12345)
        } catch {
            XCTFail()
        }
    }
    
    func test_userData_someData() async throws {
        networkingService.executeDataRequest_result = .success(Data([1, 2, 3]))
        
        let data = try await manager.userData(id: 999)
        
        XCTAssertEqual(networkingService.executeDataRequest_invocationCount, 1)
        XCTAssertEqual(
            networkingService.executeDataRequest_requests[0].url?.absoluteString,
            "https://example.com/user_data?id=999"
        )
        XCTAssertEqual(data, Data([1, 2, 3]))
    }
    
    func test_userData_noData() async {
        networkingService.executeDataRequest_result = .failure(NSError(domain: "TEST", code: 456))
        
        do {
            let _ = try await manager.userData(id: 777)
            XCTFail()
        } catch {
            let error = error as NSError
            XCTAssertEqual(error.domain, "TEST")
            XCTAssertEqual(error.code, 456)
            XCTAssertEqual(networkingService.executeDataRequest_invocationCount, 1)
            XCTAssertEqual(
                networkingService.executeDataRequest_requests[0].url?.absoluteString,
                "https://example.com/user_data?id=777"
            )
        }
    }
    
    func test_userFromData_validData() throws {
        let data = """
        {
            "name": "TEST Name",
            "hatchTimestamp": 12345
        }
        """.data(using: .utf8)!
        
        let user = try manager.userFromData(data)
        
//        XCTAssertEqual(user.name, "TEST Name")
//        XCTAssertEqual(user.hatchTimestamp, 12345)
        
        let expectedUser = BirdUser(name: "TEST Name", hatchTimestamp: 12345)
        XCTAssertEqual(user, expectedUser)
    }
    
    func test_userFromData_invalidData() {
        let data = """
        {
            "name": "TEST Name",
            "hatch_timestamp": 12345
        }
        """.data(using: .utf8)!
        
        XCTAssertThrowsError(try manager.userFromData(data))
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
