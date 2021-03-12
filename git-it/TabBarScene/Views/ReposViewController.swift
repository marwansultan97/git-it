//
//  ReposViewController.swift
//  git-it
//
//  Created by Marwan Osama on 3/8/21.
//

import UIKit
import RxSwift
import RxCocoa
import SafariServices
import DropDown

class ReposViewController: UIViewController {

    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    private let cellIdentifier = "ReposTableViewCell"
    
    private var sortDropDown = DropDown()
    
    private let bag = DisposeBag()
    
    private lazy var viewModel: ReposViewModel = {
        return ReposViewModel()
    }()
    
    private var sortBehavior = BehaviorRelay<String>(value: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        configureSearchBar()
        configureTableView()
        configureSortButton()
        bindReposList()
        bindSearchBar()
        bindTableViewPagination()
        viewModel.getRepos(basedOn: "language:Objective-C", pagination: false)
        
    }
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = .label
        let sortButton = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3.decrease"), style: .plain, target: self, action: #selector(handleDropDown))
        self.navigationItem.rightBarButtonItem = sortButton
    }
    
    private func configureSortButton() {
        sortDropDown.anchorView = navigationItem.rightBarButtonItem
        sortDropDown.dataSource = GithubConstants.programmingLanguage
        sortDropDown.bottomOffset = CGPoint(x: 0, y: (self.navigationController?.navigationBar.frame.height)!)
        sortDropDown.backgroundColor = .systemGray5
        sortDropDown.textColor = .label
        sortDropDown.selectionBackgroundColor = .systemBackground
        sortDropDown.selectedTextColor = .blue
        sortDropDown.cornerRadius = 20
        sortDropDown.shadowColor = .label
        sortDropDown.selectRow(0)
        sortDropDown.selectionAction = { [weak self] index, item in
            guard let self = self else { return }
            self.sortBehavior.accept(item)
        }
        
        sortBehavior
            .filter({ !$0.isEmpty })
            .subscribe(onNext: { [weak self] language in
                self?.viewModel.reposBehavior.accept([])
                self?.viewModel.getRepos(basedOn: "language:\(language)", pagination: false)
            }).disposed(by: bag)
        
    }
    
    @objc func handleDropDown() {
        sortDropDown.show()
    }
    
    private func configureSearchBar() {
        searchBar.searchTextField.borderStyle = .roundedRect
        searchBar.searchTextField.autocapitalizationType = .none
        searchBar.showsCancelButton = true
        searchBar.tintColor = .label
        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = UIColor.systemBackground.cgColor
        searchBar.placeholder = "Search Users..."
    }
    
    private func configureTableView() {
        tableView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 60
        tableView.keyboardDismissMode = .onDrag
        tableView.separatorStyle = .none
    }
    
    private func bindReposList() {
        viewModel.reposBehavior
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.tableView.alpha = 1
                self?.tableView.reloadData()
            }).disposed(by: bag)
        
        viewModel.noResultsBehavior
            .observe(on: MainScheduler.instance)
            .filter({ !$0.isEmpty })
            .subscribe(onNext: { [weak self] text in
                self?.tableView.alpha = 0
                self?.errorLabel.text = text
            }).disposed(by: bag)
        
    }
    
    private func bindSearchBar() {
        searchBar.rx.text.orEmpty.asObservable()
            .debounce(RxTimeInterval.milliseconds(400), scheduler: MainScheduler.instance)
            .map { query -> String in
                let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
                return trimmedQuery
            }
            .filter({ !$0.isEmpty })
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] query in
                self?.viewModel.reposBehavior.accept([])
                self?.viewModel.getRepos(basedOn: query, pagination: false)
            }).disposed(by: bag)
        
        searchBar.rx.cancelButtonClicked.subscribe(onNext: { [weak self] in
            self?.view.endEditing(true)
            self?.searchBar.text = ""
            self?.viewModel.reposBehavior.accept([])
            self?.viewModel.getRepos(basedOn: "language:swift", pagination: false)
        }).disposed(by: bag)
        
        searchBar.searchTextField.rx.controlEvent(.editingDidEndOnExit).subscribe(onNext: { [weak self] in
            self?.view.endEditing(true)
        }).disposed(by: bag)
        
        
    }
    
    private func bindTableViewPagination() {
        tableView.rx.didScroll
            .take(while: { self.searchBar.searchTextField.text!.isEmpty })
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let position = self.tableView.contentOffset.y
                let contentHeight = self.tableView.contentSize.height
                let scrollViewHeight = self.tableView.frame.height
                
                if position > contentHeight - scrollViewHeight {
                    guard !self.viewModel.isPaginating else { return }
                    print("Getting data")
                    self.viewModel.getRepos(basedOn: "language:swift", pagination: true)
                }
            }).disposed(by: bag)
    }
    

}

extension ReposViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.reposBehavior.value.isEmpty ? 8 : viewModel.reposBehavior.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ReposTableViewCell
        
        guard !viewModel.reposBehavior.value.isEmpty else {
            cell.showSkeletonAndAnimate()
            return cell
        }
        let repo = viewModel.reposBehavior.value[indexPath.row]
        cell.configureCell(repo: repo)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard !viewModel.reposBehavior.value.isEmpty else { return }
        
        let repo = viewModel.reposBehavior.value[indexPath.row]
        guard let url = URL(string: repo.htmlURL) else { return }
        let safariVC = SFSafariViewController(url: url)
        safariVC.modalPresentationStyle = .popover
        self.present(safariVC, animated: true)
        
    }
    
    
    
    
}
