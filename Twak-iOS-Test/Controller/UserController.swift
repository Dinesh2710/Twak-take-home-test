//
//  UserController.swift
//  Twak-iOS-Test
//
//  Created by Dinesh Chavda on 06/05/21.
//

import Foundation
import CoreData


typealias FetchItemsCompletionBlock = (_ success: Bool, _ error: NSError?) -> Void

// MARK: - UserControllerProtocol

protocol UserControllerProtocol {
    var items: [UserViewModel?]? { get }
    var itemCount: Int { get }

    func item(at index: Int) -> UserViewModel?
    func fetchItems(_ completionBlock: @escaping FetchItemsCompletionBlock)
}

extension UserControllerProtocol {
    var items: [UserViewModel?]? {
        return items
    }

    var itemCount: Int {
        return items?.count ?? 0
    }

    func item(at index: Int) -> UserViewModel? {
        guard index >= 0 && index < itemCount else { return nil }
        return items?[index] ?? nil
    }
}

// MARK: - UserController

class UserController: UserControllerProtocol {
    private static let entityName = "User"
    private let persistentContainer: NSPersistentContainer
    private var fetchItemsCompletionBlock: FetchItemsCompletionBlock?

    var items: [UserViewModel?]? = []

    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }

    func fetchItems(_ completionBlock: @escaping FetchItemsCompletionBlock) {
        fetchItemsCompletionBlock = completionBlock
        if let users = self.fetchFromStorage() {
            let newUsersPage = UserController.initViewModels(users)
            self.items?.removeAll()
            self.items?.append(contentsOf: newUsersPage)
            DispatchQueue.main.async {
                self.fetchItemsCompletionBlock?(true, nil)
            }
        }
        if itemCount == 0 {
            loadNextPageIfNeeded(for: 0)
        }
        
        
    }

    func item(at index: Int) -> UserViewModel? {
        
        if index + 1 == itemCount {
            let id = items?[index]?.id
            loadNextPageIfNeeded(for: id ?? 0)
            return items?[index] ?? nil
        } else {
            return items?[index] ?? nil
        }
    }
}

private extension UserController {
    func parse(_ jsonData: Data) -> Bool {
        
        do {
            guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext else {
                fatalError("Failed to retrieve managed object context")
            }

            // Parse JSON data
            let managedObjectContext = persistentContainer.viewContext
            let decoder = JSONDecoder()
            decoder.userInfo[codingUserInfoKeyManagedObjectContext] = managedObjectContext
            let users = try decoder.decode([User].self, from: jsonData)
            print(users)
            try managedObjectContext.save()

            return true
        } catch let error {
            print(error)
            return false
        }
    }

    func fetchFromStorage() -> [User]? {
        let managedObjectContext = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<User>(entityName: UserController.entityName)
        
        let sort = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        do {
            let users = try managedObjectContext.fetch(fetchRequest)
            return users
        } catch let error {
            print(error)
            return nil
        }
    }

    func clearStorage() {
        let isInMemoryStore = persistentContainer.persistentStoreDescriptions.reduce(false) {
            return $0 ? true : $1.type == NSInMemoryStoreType
        }

        let managedObjectContext = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: UserController.entityName)
        // NSBatchDeleteRequest is not supported for in-memory stores
        if isInMemoryStore {
            do {
                let users = try managedObjectContext.fetch(fetchRequest)
                for user in users {
                    managedObjectContext.delete(user as! NSManagedObject)
                }
            } catch let error as NSError {
                print(error)
            }
        } else {
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try managedObjectContext.execute(batchDeleteRequest)
            } catch let error as NSError {
                print(error)
            }
        }
    }

    static func initViewModels(_ users: [User?]) -> [UserViewModel?] {
        return users.map { user in
            if let user = user {
                return UserViewModel(profile: user)
            } else {
                return nil
            }
        }
    }

    func loadNextPageIfNeeded(for index: Int) {

        if index == 0 {
            clearStorage()
        }
        
        let urlString = String(format: "https://api.github.com/users?since=\(index)")
        print("URL======\(urlString)")
        
        guard let url = URL(string: urlString) else {
            fetchItemsCompletionBlock?(false, nil)
            return
        }
        let session = URLSession.shared
        let task = session.dataTask(with: url) { [weak self] (data, response, error) in
            guard let strongSelf = self else { return }
            guard let jsonData = data, error == nil else {
                DispatchQueue.main.async {
                    strongSelf.fetchItemsCompletionBlock?(false, error as NSError?)
                }
                return
            }
            if strongSelf.parse(jsonData) {
                if let users = strongSelf.fetchFromStorage() {
                    let newUsersPage = UserController.initViewModels(users)
                    strongSelf.items?.removeAll()
                    strongSelf.items?.append(contentsOf: newUsersPage)
                }
                DispatchQueue.main.async {
                    strongSelf.fetchItemsCompletionBlock?(true, nil)
                }
            } else {
                DispatchQueue.main.async {
                    strongSelf.fetchItemsCompletionBlock?(false, error as NSError?)
                }
            }
        }
        task.resume()
    }
}
