//
//  AuthorizationViewModel.swift
//  git-it
//
//  Created by Marwan Osama on 3/6/21.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire
import AuthenticationServices

class AuthorizationViewModel {
    
    var webAuthenticationSession: ASWebAuthenticationSession?
    
    var accessCodeBehavior = BehaviorRelay<String>(value: "")
    var tokenBehavior = BehaviorRelay<String>(value: "")
    
    
    func getAccessCode(account: String) -> ASWebAuthenticationSession? {
        var webAuthenticationSession: ASWebAuthenticationSession
        
        var authorizeURLComponents = URLComponents(string: GithubConstants.authorizeURL)
        authorizeURLComponents?.queryItems = [
            URLQueryItem(name: "client_id", value: GithubConstants.clientID),
            URLQueryItem(name: "scope", value: GithubConstants.scope),
            URLQueryItem(name: "login", value: account)
        ]
        guard let authorizeURL = authorizeURLComponents?.url else { return nil }
        
        webAuthenticationSession = ASWebAuthenticationSession.init(url: authorizeURL, callbackURLScheme: GithubConstants.redirectURI) { [weak self] (callBack: URL?, err: Error?) in
            guard let self = self else { return }
            guard err == nil, let callBack = callBack else {
                print("Error Getting Access Code: \(err!)")
                return
            }
            //Retrieve access code
            guard let callbackURL = URLComponents(string: callBack.absoluteString) else { return }
            
            guard let accessCode = callbackURL.queryItems?.first(where: { $0.name == "code" }) else { return }
            
            guard let codeValue = accessCode.value else { return }

            self.accessCodeBehavior.accept(codeValue)
    
        }
        return webAuthenticationSession
    }


    func fetchAccessToken(accessCode: String) {
        
        let url = EndPoints.fetchAccessToken().url
        let method = EndPoints.fetchAccessToken().method
        let params = EndPoints.fetchAccessToken(accessCode: accessCode).params
        let headers = EndPoints.fetchAccessToken().headers
        let encoding = EndPoints.fetchAccessToken().encoding

        NetworkServices.shared.getData(url: url, method: method, headers: headers, parameters: params, encoding: encoding) { [weak self] (tokenResult: GithubAccessToken?, err) in
            guard let self = self else { return }
            if let err = err {
                print("Error Fetching Access Token \(err)")
            } else {
                guard let token = tokenResult?.accessToken else { return }
                UserDefaults.standard.setValue(token, forKey: "token")
                self.tokenBehavior.accept(token)
            }
        }
    }
    
    
    
}
