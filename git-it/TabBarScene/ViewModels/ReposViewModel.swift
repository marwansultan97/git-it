//
//  ReposViewModel.swift
//  git-it
//
//  Created by Marwan Osama on 3/9/21.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire


class ReposViewModel {
 
    var page = 1
    var isPaginating: Bool = false
    
    var reposBehavior = BehaviorRelay<[Repo]>(value: [])
    var noResultsBehavior = BehaviorRelay<String>(value: "")
    

    
    func getRepos(basedOn language: String, pagination: Bool) {
        
        if pagination {
            page += 1
            isPaginating = true
        } else {
            page = 1
        }
        
        let url = EndPoints.fetchRepos().url
        let method = EndPoints.fetchRepos().method
        let params = EndPoints.fetchRepos(language: language, page: page).params
        let headers = EndPoints.fetchRepos().headers
        let encoding = EndPoints.fetchRepos().encoding
        
        DispatchQueue.global().asyncAfter(deadline: pagination ? .now() : .now() + 0.5) {
            NetworkServices.shared.getData(url: url, method: method, headers: headers, parameters: params, encoding: encoding) { [weak self] (result: ReposModel?, err) in
                guard let self = self else { return }
                if let err = err {
                    print(err)
                    self.noResultsBehavior.accept("Something went wrong...")
                    return
                } else {
                    guard let result = result else { return }
                    if result.items.isEmpty{
                        self.noResultsBehavior.accept("No Results")
                    } else {
                        if pagination {
                            self.isPaginating = false
                            self.reposBehavior.accept(self.reposBehavior.value + result.items)
                        } else {
                            self.reposBehavior.accept(result.items)
                        }
                    }
                }
            }
        }
    }
    
    
}
