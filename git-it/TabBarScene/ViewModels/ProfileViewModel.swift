//
//  ProfileViewModel.swift
//  git-it
//
//  Created by Marwan Osama on 3/9/21.
//

import Foundation
import RxCocoa
import RxSwift
import Alamofire

class ProfileViewModel {
    
    
    private var profileSubject = PublishRelay<ProfileModel>()
    var profileObservable: Observable<ProfileModel> {
        return profileSubject.asObservable()
    }
    
    var errorBehavior =  BehaviorRelay<String>(value: "")
    
    
    
    func getProfileData() {
        
        let url = EndPoints.fetchAuthenticatedUser.url
        let method = EndPoints.fetchAuthenticatedUser.method
        let params = EndPoints.fetchAuthenticatedUser.params
        let headers = EndPoints.fetchAuthenticatedUser.headers
        let encoding = EndPoints.fetchAuthenticatedUser.encoding
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            NetworkServices.shared.getData(url: url, method: method, headers: headers, parameters: params, encoding: encoding) { [weak self] (result: ProfileModel?, err) in
                guard let self = self else { return }
                if let err = err {
                    self.errorBehavior.accept("Something Went Wrong...")
                    print(err)
                } else {
                    guard let result = result else { return }
                    self.profileSubject.accept(result)
                }
            }
        }
        
    }
    
    
    
}
