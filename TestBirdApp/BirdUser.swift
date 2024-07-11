//
//  BirdUser.swift
//  TestBirdApp
//
//  Created by Yakov Manshin on 7/10/24.
//

import Foundation

struct BirdUser: Equatable, Decodable {
    let name: String
    let hatchTimestamp: TimeInterval
}
