//
//  UserManager.swift
//  TestBirdApp
//
//  Created by Yakov Manshin on 7/10/24.
//

import Foundation

class UserManager: UserManagerProtocol {
    
    private let networkingService: any NetworkingServiceProtocol
    private let dateFormatter: any HatchDateFormatterProtocol
    
    init(
        networkingService: any NetworkingServiceProtocol,
        dateFormatter: any HatchDateFormatterProtocol
    ) {
        self.networkingService = networkingService
        self.dateFormatter = dateFormatter
    }
    
    func infoForUser(withID id: Int) async -> String {
        do {
            let info = try await _infoForUser(withID: id)
            return info
        } catch {
            return "Cannot get info for the user with ID \(id): \(error.localizedDescription)"
        }
    }
    
    private func _infoForUser(withID id: Int) async throws -> String {
        let userData = try await userData(id: id)
        let user = try userFromData(userData)
        let relativeHatchDate = try dateFormatter.relativeHatchDate(from: user.hatchTimestamp)
        
        return "\(user.name) (ID \(id)) hatched \(relativeHatchDate) ago"
    }
    
    private func userData(id: Int) async throws -> Data {
        let request = URLRequest(url: URL(string: "https://example.com/user_data?id=\(id)")!)
        return try await networkingService.executeDataRequest(request)
    }
    
    private func userFromData(_ data: Data) throws -> BirdUser {
        try JSONDecoder().decode(BirdUser.self, from: data)
    }
    
}
