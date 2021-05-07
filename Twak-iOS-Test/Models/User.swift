//
//  UserModel.swift
//  Twak-iOS-Test
//
//  Created by Dinesh Chavda on 05/05/21.
//

import Foundation
import CoreData

class User: NSManagedObject, Codable {
    
    enum CodingKeys: String, CodingKey {
        case avatar_url = "avatar_url"
        case id = "id"
        case login = "login"
        case name = "name"
        case company = "company"
        case blog = "blog"
        case bio = "bio"
        case note = "note"
        case followers = "followers"
        case following = "following"
    }

    // MARK: - Core Data Managed Object
    @NSManaged var avatar_url: String?
    @NSManaged var id: Int64
    @NSManaged var login: String?
    @NSManaged var name: String?
    @NSManaged var company: String?
    @NSManaged var blog: String?
    @NSManaged var bio: String?
    @NSManaged var note: String?
    @NSManaged var followers: Int64
    @NSManaged var following: Int64

    // MARK: - Decodable
    required convenience init(from decoder: Decoder) throws {
        guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext,
            let managedObjectContext = decoder.userInfo[codingUserInfoKeyManagedObjectContext] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "User", in: managedObjectContext) else {
            fatalError("Failed to decode User")
        }

        self.init(entity: entity, insertInto: managedObjectContext)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.avatar_url = try container.decodeIfPresent(String.self, forKey: .avatar_url)
        self.id = try container.decodeIfPresent(Int64.self, forKey: .id) ?? 0
        self.login = try container.decodeIfPresent(String.self, forKey: .login)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.company = try container.decodeIfPresent(String.self, forKey: .company)
        self.blog = try container.decodeIfPresent(String.self, forKey: .blog)
        self.bio = try container.decodeIfPresent(String.self, forKey: .bio)
        self.note = try container.decodeIfPresent(String.self, forKey: .note)
        self.followers = try container.decodeIfPresent(Int64.self, forKey: .followers) ?? 0
        self.following = try container.decodeIfPresent(Int64.self, forKey: .following) ?? 0
    }

    // MARK: - Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(avatar_url, forKey: .avatar_url)
        try container.encode(id, forKey: .id)
        try container.encode(login, forKey: .login)
        try container.encode(name, forKey: .name)
        try container.encode(blog, forKey: .blog)
        try container.encode(bio, forKey: .bio)
        try container.encode(company, forKey: .company)
        try container.encode(note, forKey: .note)
        try container.encode(followers, forKey: .followers)
        try container.encode(following, forKey: .following)
        
    }
}


public extension CodingUserInfoKey {
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")
}
