//
//  UsersTableViewCell.swift
//  git-it
//
//  Created by Marwan Osama on 3/8/21.
//

import UIKit

class UsersTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImageView.layer.cornerRadius = userImageView.frame.height/2
        showSkeletonAndAnimate()
    }
    
    func showSkeletonAndAnimate() {
        userImageView.showAnimatedSkeleton()
        usernameLabel.showAnimatedSkeleton()
    }
    
    func hideSkeletonAndAnimate() {
        userImageView.hideSkeleton()
        usernameLabel.hideSkeleton()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(user: User) {
        hideSkeletonAndAnimate()
        usernameLabel.text = user.login
        userImageView.kf.setImage(with: URL(string: user.avatarURL))
    }
    
}
