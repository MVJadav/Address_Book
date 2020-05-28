//
//  userCell.swift
//  MehulJadavTestDemo
//

import UIKit

class userCell: UITableViewCell {

    @IBOutlet weak var imgProfile       : UIImageView!
    @IBOutlet weak var lblName          : UILabel!
    @IBOutlet weak var lblNumber        : UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.imgProfile.roundSquareImage()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var userInfo: User? {
        didSet {
        
            if let name = userInfo?.name {
                self.lblName.text = name
            }
            if let number = userInfo?.number {
                self.lblNumber.text = number
            }
            if let imgData = userInfo?.image {
                if let userImg = UIImage(data: imgData) {
                    self.imgProfile?.image = userImg
                } else {
                    self.imgProfile?.image = UIImage(named: "ic_loginUser")
                }
            }
            
        }
    }
}
extension UIImageView {
    /// EZSwiftExtensions
    public func roundSquareImage() {
        self.clipsToBounds = true
        self.layer.cornerRadius = self.frame.size.width / 2
    }
}
