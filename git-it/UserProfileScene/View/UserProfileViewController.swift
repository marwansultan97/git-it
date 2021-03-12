//
//  UserProfileViewController.swift
//  git-it
//
//  Created by Marwan Osama on 3/10/21.
//

import UIKit
import RxCocoa
import RxSwift
import ChameleonFramework

class UserProfileViewController: UIViewController {

    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userLoginLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var staticPersonImageView: UIImageView!
    
    
    var accountName: String?
    
    private let cellIdentifier = "ProfileTableViewCell"
    
    private var cellOptions = [ProfileCellOption]()
    
    private let bag = DisposeBag()
    
    private lazy var viewModel: UserProfileViewModel = {
        return UserProfileViewModel(accountName: accountName!)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureTableView()
        showSkeletonAndAnimate()
        bindProfileDetails()
        viewModel.getProfileData()
        
        
    }
    
    private func configureUI() {
        userImageView.layer.cornerRadius = userImageView.frame.height / 2
        userNameLabel.adjustsFontSizeToFitWidth = true
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
    }
    
    private func bindProfileDetails() {
        viewModel.profileObservable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] profile in
                self?.containerView.alpha = 1
                let url = profile.avatarURL
                self?.userImageView.kf.setImage(with: URL(string: url))
                self?.userNameLabel.text = profile.name
                self?.userLoginLabel.text = profile.login
                self?.followersLabel.text = "\(profile.followers) followers , \(profile.following) followings"
                
                
                self?.cellOptions = [
                    ProfileCellOption(name: "Repositories", icon: UIImage(systemName: "book.closed")!, imageBackgroundColor: FlatNavyBlue(), handler: {
                        self?.goToProfileReposVC(title: "Repositories",
                                                 accountName: profile.login,
                                                 useCase: .profileRepos)
                    }),
                    ProfileCellOption(name: "Starred", icon: UIImage(systemName: "star")!, imageBackgroundColor: FlatYellowDark(), handler: {
                        self?.goToProfileReposVC(title: "Starred",
                                                 accountName: profile.login,
                                                 useCase: .starredRepos)
                    })
                ]
                
                self?.tableView.reloadData()
                self?.hideSkeletonAndAnimate()
            }).disposed(by: bag)
        
        viewModel.errorBehavior
            .filter({ !$0.isEmpty })
            .subscribe(onNext: { [weak self] err in
                self?.containerView.alpha = 0
                self?.errorLabel.text = err
            }).disposed(by: bag)
    }
    

    private func showSkeletonAndAnimate() {
        userImageView.showAnimatedSkeleton()
        userNameLabel.showAnimatedSkeleton()
        userLoginLabel.showAnimatedSkeleton()
        followersLabel.showAnimatedSkeleton()
        staticPersonImageView.showAnimatedSkeleton()
    }
    
    private func hideSkeletonAndAnimate() {
        userImageView.hideSkeleton()
        userNameLabel.hideSkeleton()
        userLoginLabel.hideSkeleton()
        followersLabel.hideSkeleton()
        staticPersonImageView.hideSkeleton()
    }
    
    private func goToProfileReposVC(title: String, accountName: String, useCase: ProfileRepositoriesUseCase) {
        let vc = UIStoryboard(name: "ProfileRepositories", bundle: nil).instantiateInitialViewController() as? ProfileRepositoriesViewController
        vc?.title = title
        vc?.accountName = accountName
        vc?.useCase = useCase
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    


}

extension UserProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ProfileTableViewCell
        guard !cellOptions.isEmpty else {
            cell.showSkeletonAndAnimate()
            return cell
        }
        
        let model = cellOptions[indexPath.row]
        cell.iconImageView.image = model.icon
        cell.imageContainerView.backgroundColor = model.imageBackgroundColor
        cell.nameLabel.text = model.name
        cell.hideSkeletonAndAnimate()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard !cellOptions.isEmpty else { return }
        let cellHandler = cellOptions[indexPath.row]
        cellHandler.handler!()
        
    }
    
}
