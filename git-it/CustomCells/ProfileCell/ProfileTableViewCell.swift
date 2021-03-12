//
//  ProfileTableViewCell.swift
//  git-it
//
//  Created by Marwan Osama on 3/9/21.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageContainerView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        showSkeletonAndAnimate()
        imageContainerView.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func showSkeletonAndAnimate() {
        imageContainerView.showAnimatedSkeleton()
        nameLabel.showAnimatedSkeleton()
        iconImageView.showAnimatedSkeleton()
    }
    
    func hideSkeletonAndAnimate() {
        imageContainerView.hideSkeleton()
        nameLabel.hideSkeleton()
        iconImageView.hideSkeleton()
    }
    
    
}
