//
//  UserViewModel.swift
//  Twak-iOS-Test
//
//  Created by Dinesh Chavda on 06/05/21.
//

import Foundation


struct UserViewModel {
    let avatarUrl: String
    let id: Int
    let username: String
    let name: String
    let blog: String
    let bio: String
    let note: String
    let company: String
    let followers: Int
    let following: Int
    
    init(profile: User) {
        avatarUrl = profile.avatar_url ?? ""
        id = Int(profile.id)
        username = profile.login ?? ""
        name = profile.name ?? ""
        company = profile.company ?? ""
        blog = profile.blog ?? ""
        bio = profile.bio ?? ""
        note = profile.note ?? ""
        followers = Int(profile.followers)
        following = Int(profile.following)
    }
}

extension UserViewModel: Equatable {}

func ==(lhs: UserViewModel, rhs: UserViewModel) -> Bool {
    return lhs.avatarUrl == rhs.avatarUrl &&
        lhs.username == rhs.username
}
