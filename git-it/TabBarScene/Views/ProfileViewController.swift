//
//  ProfileViewController.swift
//  git-it
//
//  Created by Marwan Osama on 3/9/21.
//

import UIKit
import RxSwift
import RxCocoa
import ChameleonFramework

struct ProfileCellOption {
    let name: String
    let icon: UIImage
    let imageBackgroundColor: UIColor
    var handler: (()->Void)?
}


class ProfileViewController: UIViewController {

    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var profileLoginLabel: UILabel!
    @IBOutlet weak var followLabel: UILabel!
    @IBOutlet weak var staticPersonImageView: UIImageView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    private let cellIdentifier = "ProfileTableViewCell"
    
    private var cellOptions = [ProfileCellOption]()
    
    private let bag = DisposeBag()
    
    private lazy var viewModel: ProfileViewModel = {
        return ProfileViewModel()
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        configureNavigationBar()
        configureTableView()
        showSkeletonAndAnimate()
        bindProfileDetails()
        viewModel.getProfileData()

    }
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = .label
        let logoutButton = UIBarButtonItem(image: UIImage(systemName: "person.crop.circle.badge.xmark.fill"), style: .plain, target: self, action: #selector(handleLogOut))
        navigationItem.rightBarButtonItem = logoutButton
    }
    
    @objc func handleLogOut() {
        let alert = UIAlertController(title: "Logout", message: "Are you sure you logout from your Github account?", preferredStyle: .alert)
        let logoutAction = UIAlertAction(title: "Logout", style: .destructive) { _ in
            
            
            let authorizationVC = UIStoryboard(name: "Authorization", bundle: nil).instantiateViewController(identifier: "Authorization")
            
            
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                print("No window Scene")
                return
            }
            
            guard let sceneDelegate = windowScene.delegate as? SceneDelegate else {
                print("No Scene Delegate")
                return
            }
            
            if let rootNav = sceneDelegate.window?.rootViewController as? UINavigationController {
                UserDefaults.standard.removeObject(forKey: "token")
                rootNav.pushViewController(authorizationVC, animated: true)
            }
            
            
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(logoutAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func configureUI() {
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileNameLabel.adjustsFontSizeToFitWidth = true

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
                self?.profileImageView.kf.setImage(with: URL(string: url))
                self?.profileNameLabel.text = profile.name
                self?.profileLoginLabel.text = profile.login
                self?.followLabel.text = "\(profile.followers) followers , \(profile.following) followings"
                
                
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
    
    private func goToProfileReposVC(title: String, accountName: String, useCase: ProfileRepositoriesUseCase) {
        let vc = UIStoryboard(name: "ProfileRepositories", bundle: nil).instantiateInitialViewController() as? ProfileRepositoriesViewController
        vc?.title = title
        vc?.accountName = accountName
        vc?.useCase = useCase
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    private func showSkeletonAndAnimate() {
        profileImageView.showAnimatedSkeleton()
        profileNameLabel.showAnimatedSkeleton()
        profileLoginLabel.showAnimatedSkeleton()
        followLabel.showAnimatedSkeleton()
        staticPersonImageView.showAnimatedSkeleton()
    }
    
    private func hideSkeletonAndAnimate() {
        profileImageView.hideSkeleton()
        profileNameLabel.hideSkeleton()
        profileLoginLabel.hideSkeleton()
        followLabel.hideSkeleton()
        staticPersonImageView.hideSkeleton()
    }
    

}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
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
