//
//  UsersViewModel.swift
//  git-it
//
//  Created by Marwan Osama on 3/7/21.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire

class UsersViewModel {
    
    var page = 1
    var isPaginating: Bool = false
    
    var usersBehavior = BehaviorRelay<[User]>(value: [])
    var noResultsBehavior = BehaviorRelay<String>(value: "")
    

    
    func getUsers(basedOn language: String, pagination: Bool) {
        
        if pagination {
            page += 1
            isPaginating = true
        } else {
            page = 1
        }
        
//        let url = "https://api.github.com/search/users"
//        let params: [String: Any] = [
//            "sort": "stars",
//            "orded": "desc",
//            "q": language,
//            "page": page
//        ]
        let url = EndPoints.fetchUsers().url
        let method = EndPoints.fetchUsers().method
        let params = EndPoints.fetchUsers(language: language, page: page).params
        let headers = EndPoints.fetchUsers().headers
        let encoding = EndPoints.fetchUsers().encoding
        
        DispatchQueue.global().asyncAfter(deadline: pagination ? .now() : .now() + 0.5) {
            NetworkServices.shared.getData(url: url, method: method, headers: headers, parameters: params, encoding: encoding) { [weak self] (result: UsersModel?, err) in
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
                            self.usersBehavior.accept(self.usersBehavior.value + result.items)
                        } else {
                            self.usersBehavior.accept(result.items)
                        }

                    }
                                        
                    
                }
            }
        }
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
}
