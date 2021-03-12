//
//  ProfileRepositoriesViewController.swift
//  git-it
//
//  Created by Marwan Osama on 3/10/21.
//

import UIKit
import RxCocoa
import RxSwift
import SafariServices

enum ProfileRepositoriesUseCase {
    case profileRepos
    case starredRepos
}

class ProfileRepositoriesViewController: UIViewController {

    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var accountName: String?
    var useCase: ProfileRepositoriesUseCase?
    
    private let repoCellIdentifier = "ProfileRepositoriesTableViewCell"
    private let starredCellIdentifier = "StarredTableViewCell"
    
    private let bag = DisposeBag()
    
    private lazy var viewModel: ProfileRepositoriesViewModel = {
        return ProfileRepositoriesViewModel(accountName: accountName!)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        bindDataResult()
        getData()
        
        
    }
    
    private func getData() {
        switch useCase {
        case .profileRepos:
            viewModel.getRepos()
        case .starredRepos:
            viewModel.getStarred()
        case .none:
            break
        }
    }
    
    private func bindDataResult() {
        viewModel.reposBehaviorRelay
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.tableView.alpha = 1
                self?.tableView.reloadData()
            }).disposed(by: bag)
        
        viewModel.errorRelay
            .observe(on: MainScheduler.instance)
            .filter({ !$0.isEmpty })
            .subscribe(onNext: { [weak self] text in
                self?.tableView.alpha = 0
                self?.errorLabel.text = text
            }).disposed(by: bag)
    }
    
    private func configureTableView() {
        tableView.register(UINib(nibName: repoCellIdentifier, bundle: nil), forCellReuseIdentifier: repoCellIdentifier)
        tableView.register(UINib(nibName: starredCellIdentifier, bundle: nil), forCellReuseIdentifier: starredCellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        
        switch useCase {
        case .profileRepos:
            tableView.rowHeight = 80
        case.starredRepos:
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 150
        case .none:
            break
        }
    }

    

}

extension ProfileRepositoriesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch useCase {
        case.profileRepos:
            return viewModel.reposBehaviorRelay.value.isEmpty ? 5 : viewModel.reposBehaviorRelay.value.count
        case.starredRepos:
            return viewModel.reposBehaviorRelay.value.isEmpty ? 5 : viewModel.reposBehaviorRelay.value.count
        case .none:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch useCase {
        
        case .profileRepos:
            let cell = tableView.dequeueReusableCell(withIdentifier: repoCellIdentifier, for: indexPath) as! ProfileRepositoriesTableViewCell
            
            guard !viewModel.reposBehaviorRelay.value.isEmpty else {
                cell.showSkeletonAndAnimate()
                return cell
            }
            let repo = viewModel.reposBehaviorRelay.value[indexPath.row]
            cell.configureCell(repo: repo)
            return cell

        case .starredRepos:
            let cell = tableView.dequeueReusableCell(withIdentifier: starredCellIdentifier, for: indexPath) as! StarredTableViewCell
            
            guard !viewModel.reposBehaviorRelay.value.isEmpty else {
                cell.showSkeletonAndAnimate()
                return cell
            }
            let repo = viewModel.reposBehaviorRelay.value[indexPath.row]
            cell.configureCell(repo: repo)
            return cell
            
        case .none:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard !viewModel.reposBehaviorRelay.value.isEmpty else { return }
        
        let repo = viewModel.reposBehaviorRelay.value[indexPath.row]
        guard let url = URL(string: repo.htmlURL) else { return }
        let safariVC = SFSafariViewController(url: url)
        safariVC.modalPresentationStyle = .popover
        self.present(safariVC, animated: true, completion: nil)
        
        
    }
    
    
}
