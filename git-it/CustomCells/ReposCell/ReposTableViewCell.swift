//
//  ReposTableViewCell.swift
//  git-it
//
//  Created by Marwan Osama on 3/8/21.
//

import UIKit

class ReposTableViewCell: UITableViewCell {

    @IBOutlet weak var repoNameLabel: UILabel!
    @IBOutlet weak var repoDescLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        showSkeletonAndAnimate()
    }
    
    func showSkeletonAndAnimate() {
        repoNameLabel.showAnimatedSkeleton()
        repoDescLabel.showAnimatedSkeleton()
    }
    
    func hideSkeletonAndAnimate() {
        repoNameLabel.hideSkeleton()
        repoDescLabel.hideSkeleton()
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(repo: Repo) {
        hideSkeletonAndAnimate()
        repoNameLabel.text = repo.fullName
        repoDescLabel.text = repo.itemDescription ?? ""
    }
    
    
    
    
}
