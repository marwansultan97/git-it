//
//  ProfileRepositoriesViewModel.swift
//  git-it
//
//  Created by Marwan Osama on 3/10/21.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire


class ProfileRepositoriesViewModel {
    
    var accountName: String
    
    init(accountName: String) {
        self.accountName = accountName
    }
    
    var reposBehaviorRelay = BehaviorRelay<[ProfileRepositoriesModelElement]>(value: [])
    var errorRelay = BehaviorRelay<String>(value: "")
    
    func getRepos() {

        let url = EndPoints.fetchUserRepos(accountName: accountName).url
        let method = EndPoints.fetchUserRepos().method
        let params = EndPoints.fetchUserRepos().params
        let headers = EndPoints.fetchUserRepos().headers
        let encoding = EndPoints.fetchUserRepos().encoding
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
            NetworkServices.shared.getData(url: url, method: method, headers: headers, parameters: params, encoding: encoding) { [weak self] (result: [ProfileRepositoriesModelElement]?, err) in
                guard let self = self else { return }
                if let err = err {
                    print(err)
                    self.errorRelay.accept("Something went wrong...")
                } else {
                    guard let result = result else { return }
                    if result.isEmpty {
                        self.errorRelay.accept("There aren't any Repositories")
                    } else {
                        self.reposBehaviorRelay.accept(result)
                    }
                    
                }
            }
        }
 
    }
    
    func getStarred() {
        
        let url = EndPoints.fetchUserStarred(accountName: accountName).url
        let method = EndPoints.fetchUserStarred().method
        let params = EndPoints.fetchUserStarred().params
        let headers = EndPoints.fetchUserStarred().headers
        let encoding = EndPoints.fetchUserStarred().encoding
        
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
            NetworkServices.shared.getData(url: url, method: method, headers: headers, parameters: params, encoding: encoding) { [weak self] (result: [ProfileRepositoriesModelElement]?, err) in
                guard let self = self else { return }
                if let err = err {
                    print(err)
                    self.errorRelay.accept("Something went wrong...")
                } else {
                    guard let result = result else { return }
                    if result.isEmpty {
                        self.errorRelay.accept("There aren't any Repositories")
                    } else {
                        self.reposBehaviorRelay.accept(result)
                    }
                    
                }
            }
        }
 
    }

    
    
    
    
    
    
    
}
