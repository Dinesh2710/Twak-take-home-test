//
//  tableCell.swift
//  Twak-iOS-Test
//
//  Created by Dinesh Chavda on 05/05/21.
//

import UIKit

class tableCell: UITableViewCell {
    
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblDetails: UILabel!
    @IBOutlet weak var btnNote: UIButton!
    @IBOutlet weak var vwbackground: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        self.imgView.layer.cornerRadius = 30
        self.imgView.layer.borderWidth = 1
        self.imgView.layer.borderColor = UIColor.black.cgColor
        
        self.vwbackground.layer.borderColor = UIColor.black.cgColor
        self.vwbackground.layer.borderWidth = 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func setDataInCell(_ user : UserViewModel, isInvert : Bool) {
        self.lblUsername.text = user.username
        self.lblDetails.text = user.username
        self.imgView.image = UIImage()
        
        
        self.imgView.downloaded(from: URL(string: user.avatarUrl)!, isInvert: isInvert, withUser: user.username)
    }
    
}



