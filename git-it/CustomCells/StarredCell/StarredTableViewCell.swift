//
//  StarredTableViewCell.swift
//  git-it
//
//  Created by Marwan Osama on 3/10/21.
//

import UIKit
import ChameleonFramework
import Kingfisher

class StarredTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var ownerImageView: UIImageView!
    @IBOutlet weak var ownerNameLabel: UILabel!
    @IBOutlet weak var repoNameLabel: UILabel!
    @IBOutlet weak var repoDescriptionLabel: UILabel!
    @IBOutlet weak var staticStarImageView: UIImageView!
    @IBOutlet weak var starNumberLabel: UILabel!
    @IBOutlet weak var solidCircleView: UIView!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        ownerImageView.layer.cornerRadius = ownerImageView.frame.height / 2
        solidCircleView.layer.cornerRadius = solidCircleView.frame.height / 2
        solidCircleView.alpha = 0
        showSkeletonAndAnimate()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func showSkeletonAndAnimate() {
//        showAnimatedSkeleton()
        ownerImageView.showAnimatedSkeleton()
        repoNameLabel.showAnimatedSkeleton()
        ownerNameLabel.showAnimatedSkeleton()
//        staticStarImageView.showAnimatedSkeleton()
//        starNumberLabel.showAnimatedSkeleton()
//        languageLabel.showAnimatedSkeleton()
        repoDescriptionLabel.showAnimatedSkeleton()
//        solidCircleView.showAnimatedSkeleton()
        bottomView.showAnimatedSkeleton()
    }
    
    func hideSkeletonAndAnimate() {
        hideSkeleton()
    }
    
    
    func configureCell(repo: ProfileRepositoriesModelElement) {
        let url = repo.owner.avatarURL
        ownerImageView.kf.setImage(with: URL(string: url))
        ownerNameLabel.text = repo.owner.login
        repoNameLabel.text = repo.name
        repoDescriptionLabel.text = repo.profileRepositoriesModelDescription ?? ""
        starNumberLabel.text = "\(repo.stargazersCount)"
        
        if let language = repo.language {
            languageLabel.text = language
            solidCircleView.alpha = 1
        }
        hideSkeletonAndAnimate()
    }
    
    
    
    
}
