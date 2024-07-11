//
//  UserManagerProtocol.swift
//  TestBirdApp
//
//  Created by Yakov Manshin on 7/10/24.
//

import Foundation

protocol UserManagerProtocol {
    
    func infoForUser(withID id: Int) async -> String
    
}
