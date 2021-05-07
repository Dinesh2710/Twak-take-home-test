//
//  ProfileController.swift
//  Twak-iOS-Test
//
//  Created by Dinesh Chavda on 07/05/21.
//

import Foundation
import CoreData

protocol ProfileControllerProtocol {
    
    var items: UserViewModel? { get }
    
    func fetchItems(withUser name : String ,_ completionBlock: @escaping FetchItemsCompletionBlock)
    
    func updateProfile(withUser name : String,withNote note : String ,_ completionBlock: @escaping FetchItemsCompletionBlock)
}

extension ProfileControllerProtocol {
    var items: UserViewModel? {
        return items
    }
}


class ProfileController : ProfileControllerProtocol {
    
    private static let entityName = "User"
    private let persistentContainer: NSPersistentContainer

    private var fetchItemsCompletionBlock: FetchItemsCompletionBlock?
    
    var items : UserViewModel?
    
    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }
    
    func fetchItems(withUser name : String,_ completionBlock: @escaping FetchItemsCompletionBlock) {
        fetchItemsCompletionBlock = completionBlock
        
        let managedObjectContext = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<User>(entityName: ProfileController.entityName)
        fetchRequest.predicate = NSPredicate(format: "login == %@", name)
        do {
            let profile = try managedObjectContext.fetch(fetchRequest)
            let user = profile[0]
            let ur = UserViewModel(profile: user)
            if ur.name.count != 0 || ur.company.count != 0 || ur.blog.count != 0 || ur.bio.count != 0 {
                self.items = ur
                DispatchQueue.main.async {
                    self.fetchItemsCompletionBlock?(true, nil)
                }
            } else {
                self.loadUserProfile(for: name) { (results) in
                    user.name = results?["name"] as? String ?? ""
                    user.company = results?["company"] as? String ?? ""
                    user.bio = results?["bio"] as? String ?? ""
                    user.blog = results?["blog"] as? String ?? ""
                    user.followers = Int64(Int(results?["followers"] as? Int ?? 0))
                    user.following = Int64(Int(results?["following"] as? Int ?? 0))
                    user.note = results?["note"] as? String ?? ""
                    
                    let ur = UserViewModel(profile: user)
                    self.items = ur
                    do {
                        try managedObjectContext.save()
                        DispatchQueue.main.async {
                            self.fetchItemsCompletionBlock?(true, nil)
                        }
                    } catch let err {
                        DispatchQueue.main.async {
                            self.fetchItemsCompletionBlock?(false, err as NSError)
                        }
                    }
                    
                    
                    
                }
            }
            
        } catch let error {
            print(error)
            DispatchQueue.main.async {
                self.fetchItemsCompletionBlock?(false, error as NSError)
            }
        }
    }
    
    func fetchFromStorage(withUser username : String) -> [User]? {
        let managedObjectContext = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<User>(entityName: ProfileController.entityName)
        fetchRequest.predicate = NSPredicate(format: "login == %@", username)
        do {
            let profile = try managedObjectContext.fetch(fetchRequest)
            return profile
        } catch let error {
            print(error)
            return nil
        }
    }
    
    func updateProfile(withUser name : String,withNote note : String,_ completionBlock: @escaping FetchItemsCompletionBlock) {
        fetchItemsCompletionBlock = completionBlock
        
        let managedObjectContext = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<User>(entityName: ProfileController.entityName)
        fetchRequest.predicate = NSPredicate(format: "login == %@", name)
        do {
            let profile = try managedObjectContext.fetch(fetchRequest)
            let pf = profile[0] as User
            pf.note = note
            self.items = UserViewModel(profile: pf)
            do {
                try managedObjectContext.save()
                DispatchQueue.main.async {
                    self.fetchItemsCompletionBlock?(true, nil)
                }
            }catch let err {
                DispatchQueue.main.async {
                    self.fetchItemsCompletionBlock?(false, err as NSError)
                }
            }
        } catch let error {
            print(error)
            DispatchQueue.main.async {
                self.fetchItemsCompletionBlock?(false, error as NSError)
            }
        }
    }
    
    
    func convertToDictionary(jsonData: Data?) -> [String: Any]? {
        if let data = jsonData {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    
    func loadUserProfile(for Username: String,completion block : @escaping ([String:Any]?) -> Void) {

        let urlString = String(format: "https://api.github.com/users/\(Username)")
        
        guard let url = URL(string: urlString) else {
            return
        }
        let session = URLSession.shared
        let task = session.dataTask(with: url) { [weak self] (data, response, error) in
            guard let strongSelf = self else { return }
            guard let jsonData = data, error == nil else {
                return block(nil)
            }
            block(strongSelf.convertToDictionary(jsonData: jsonData))
            
        }
        task.resume()
    }
    
}
