//
//  Tags.swift
//  TestBirdTests
//
//  Created by Yakov Manshin on 9/28/24.
//

import Testing

// Define custom tags for your tests:
extension Tag {
    @Tag static var required: Self
    @Tag static var important: Self
    @Tag static var optional: Self
}

// You can have nested categories too:

extension Tag {
    enum AppScreen { }
    enum Role { }
}

extension Tag.AppScreen {
    @Tag static var home: Tag
    @Tag static var profile: Tag
    @Tag static var settings: Tag
}

extension Tag.Role {
    @Tag static var businessLogic: Tag
    @Tag static var inputHandling: Tag
    @Tag static var presentation: Tag
}
