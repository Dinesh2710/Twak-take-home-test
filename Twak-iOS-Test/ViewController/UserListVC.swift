//
//  UserListVC.swift
//  Twak-iOS-Test
//
//  Created by Dinesh Chavda on 05/05/21.
//

import UIKit
import CoreData


class UserListVC: UIViewController {
    
    
    @IBOutlet weak var srchBar: UISearchBar!
    @IBOutlet weak var tblView: UITableView!
    
    private static let UserCellReuseId = "tableCell"
    private var userController: UserControllerProtocol?
    
    let network: NetworkManager = NetworkManager.sharedInstance
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NetworkManager.isUnreachable { _ in
            self.showOfflinePage()
        }
        
        self.userController = UserController(persistentContainer: appDelegate.persistentContainer)
        
        self.tblView.register(UINib(nibName: UserListVC.UserCellReuseId, bundle: nil), forCellReuseIdentifier: UserListVC.UserCellReuseId)
        
        self.tblView.delegate = self
        self.tblView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        userController?.fetchItems { [weak self] (success, error) in
            
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self?.view ?? UIView(), animated: true)
                
                if !success {
                    let title = "Error"
                    if let error = error {
                        strongSelf.showError(title, message: error.localizedDescription)
                    } else {
                        strongSelf.showError(title, message: NSLocalizedString("Can't retrieve Users.", comment: "Can't retrieve Users."))
                    }
                } else {
                    strongSelf.tblView.reloadData()
                }
            }
            
            
        }
    }
    
    private func showOfflinePage() -> Void {
        DispatchQueue.main.async {
            let offline = self.storyboard?.instantiateViewController(identifier: "OfflineViewController") as! OfflineViewController
            self.present(offline, animated: true, completion: nil)
        }
    }
    
}



//MARK: TableView Delegate

extension UserListVC : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userController?.itemCount ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: UserListVC.UserCellReuseId, for: indexPath) as! tableCell
        
        if let user = userController?.item(at: indexPath.row) {
            
            if user.note.count != 0 {
                cell.btnNote.isHidden = false
            } else {
                cell.btnNote.isHidden = true
            }
            
            if (indexPath.row + 1) % 4 == 0 {
                cell.setDataInCell(user, isInvert: true)
            } else {
                cell.setDataInCell(user, isInvert: false)
            }
        } else {
            
        }
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tblView.deselectRow(at: indexPath, animated: true)
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileVC
        vc.userName = self.userController?.item(at: indexPath.row)?.username
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
}
