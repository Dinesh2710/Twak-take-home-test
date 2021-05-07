//
//  OfflineViewController.swift
//  Twak-iOS-Test
//
//  Created by Dinesh Chavda on 07/05/21.
//

import UIKit

class OfflineViewController: UIViewController {

    let network: NetworkManager = NetworkManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        network.reachability.whenReachable = { reachability in
            self.showMainController()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func showMainController() -> Void {
        DispatchQueue.main.async {
            self.dismiss(animated: true) {}
        }
    }
    
    @IBAction func btnRetry_Action(_ sender: UIButton) {
        network.reachability.whenReachable = { reachability in
            self.showMainController()
        }
    }

}
