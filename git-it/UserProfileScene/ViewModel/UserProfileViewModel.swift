//
//  UserProfileViewModel.swift
//  git-it
//
//  Created by Marwan Osama on 3/10/21.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire

class UserProfileViewModel {
    
    var accountName: String
    
    init(accountName: String) {
        self.accountName = accountName
    }
    
    
    private var profileSubject = PublishRelay<ProfileModel>()
    var profileObservable: Observable<ProfileModel> {
        return profileSubject.asObservable()
    }
    
    var errorBehavior =  BehaviorRelay<String>(value: "")
    
    
    
    func getProfileData() {
        
        let url = EndPoints.fetchSpecificUser(accountName: accountName).url
        let method = EndPoints.fetchSpecificUser().method
        let params = EndPoints.fetchSpecificUser().params
        let headers = EndPoints.fetchSpecificUser().headers
        let encoding = EndPoints.fetchSpecificUser().encoding
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            NetworkServices.shared.getData(url: url, method: method, headers: headers, parameters: params, encoding: encoding) { [weak self] (result: ProfileModel?, err) in
                guard let self = self else { return }
                if let err = err {
                    self.errorBehavior.accept("Something Went Wrong...")
                    print(err)
                } else {
                    guard let result = result else { return }
                    self.profileSubject.accept(result)
                    print(result.login)
                }
            }
        }
        
    }
    
    
    
    
}
