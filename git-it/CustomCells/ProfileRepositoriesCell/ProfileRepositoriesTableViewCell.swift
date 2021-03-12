//
//  ProfileRepositoriesTableViewCell.swift
//  git-it
//
//  Created by Marwan Osama on 3/10/21.
//

import UIKit
import ChameleonFramework

class ProfileRepositoriesTableViewCell: UITableViewCell {

    @IBOutlet weak var repoNameLabel: UILabel!
    @IBOutlet weak var staticStarImageView: UIImageView!
    @IBOutlet weak var starNumberLabel: UILabel!
    @IBOutlet weak var solidCircleView: UIView!
    @IBOutlet weak var languageLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        solidCircleView.alpha = 0
        solidCircleView.layer.cornerRadius = solidCircleView.frame.height / 2
        showSkeletonAndAnimate()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func showSkeletonAndAnimate() {
        showAnimatedSkeleton()
    }
    
    func hideSkeletonAndAnimate() {
        hideSkeleton()
    }
    
    func configureCell(repo: ProfileRepositoriesModelElement) {
        repoNameLabel.text = repo.name
        starNumberLabel.text = "\(repo.stargazersCount)"
        
        if let language = repo.language {
            languageLabel.text = language
            solidCircleView.alpha = 1
        }
        
        
        solidCircleView.backgroundColor = FlatYellow()
        hideSkeletonAndAnimate()
    }
    
    
    
    
}
