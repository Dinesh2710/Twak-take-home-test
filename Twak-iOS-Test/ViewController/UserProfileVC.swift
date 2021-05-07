//
//  UserProfileVC.swift
//  Twak-iOS-Test
//
//  Created by Dinesh Chavda on 05/05/21.
//

import UIKit

class UserProfileVC: KeyboardHandlingBaseVC, UITextViewDelegate {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblTitleName: UILabel!
    @IBOutlet weak var lblFollowing: UILabel!
    @IBOutlet weak var lblFollowers: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblCompany: UILabel!
    @IBOutlet weak var lblBlog: UILabel!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var txtView: UITextView!
    
    let network: NetworkManager = NetworkManager.sharedInstance
    var userName : String? = ""
    private var profileController: ProfileControllerProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NetworkManager.isUnreachable { _ in
            self.showOfflinePage()
        }
        
        txtView.delegate = self
        
        self.profileController = ProfileController(persistentContainer: appDelegate.persistentContainer)
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        self.profileController?.fetchItems(withUser: userName ?? "", { [weak self] (success, error) in
            
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
                    strongSelf.setData(user: (strongSelf.profileController?.items)!)
                }
            }
        })
    }
    
    private func showOfflinePage() -> Void {
        DispatchQueue.main.async {
            let offline = self.storyboard?.instantiateViewController(identifier: "OfflineViewController") as! OfflineViewController
            self.present(offline, animated: true, completion: nil)
        }
    }
    
    func setData(user : UserViewModel) {
        self.lblTitleName.text = user.username
        
        if let url = URL(string: user.avatarUrl) {
            self.imgView.downloaded(from: url, isInvert: false, withUser: user.username)
        }
        
        self.lblFollowers.text = "Followers : \(user.followers)"
        self.lblFollowing.text = "Following : \(user.following)"
        
        self.lblName.text = user.name
        self.lblCompany.text = user.company
        self.lblBlog.text = user.blog
        self.txtView.text = user.note
    }
    
    @IBAction func btnBack_Action(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSave_Action(_ sender: UIButton) {
        self.profileController?.updateProfile(withUser: userName ?? "",withNote: txtView.text, { [weak self](success, error) in
            
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: strongSelf.view, animated: true)
                if !success {
                    let title = "Error"
                    if let error = error {
                        strongSelf.showError(title, message: error.localizedDescription)
                    } else {
                        strongSelf.showError(title, message: NSLocalizedString("Can't retrieve Users.", comment: "Can't retrieve Users."))
                    }
                } else {
                    print(strongSelf.profileController?.items)
                    strongSelf.setData(user: (strongSelf.profileController?.items)!)
                }
            }
            
        })
        
    }
    
}

extension UserProfileVC {
    
}
