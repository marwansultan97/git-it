//
//  EndPoints.swift
//  git-it
//
//  Created by Marwan Osama on 3/11/21.
//

import UIKit
import Alamofire


enum EndPoints {
    
    case fetchAccessToken(accessCode: String? = nil)
    case fetchUsers(language: String? = nil, page: Int? = nil)
    case fetchRepos(language: String? = nil, page: Int? = nil)
    case fetchAuthenticatedUser
    case fetchUserRepos(accountName: String? = nil)
    case fetchUserStarred(accountName: String? = nil)
    case fetchSpecificUser(accountName: String? = nil)
    
    
    
    var url: String {
        switch self {
        case .fetchAccessToken:
            return "https://github.com/login/oauth/access_token"
        case .fetchUsers:
            return "https://api.github.com/search/users"
        case .fetchRepos:
            return "https://api.github.com/search/repositories"
        case .fetchAuthenticatedUser:
            return "https://api.github.com/user"
        case .fetchUserRepos(accountName: let accountName):
            return "https://api.github.com/users/\(accountName!)/repos"
        case .fetchUserStarred(accountName: let accountName):
            return "https://api.github.com/users/\(accountName!)/starred"
        case .fetchSpecificUser(accountName: let accountName):
            return "https://api.github.com/users/\(accountName!)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .fetchAccessToken:
            return .post
        case .fetchUsers:
            return .get
        case .fetchRepos:
            return .get
        case .fetchAuthenticatedUser:
            return .get
        case .fetchUserRepos:
            return .get
        case .fetchUserStarred:
            return .get
        case .fetchSpecificUser:
            return .get
        }
    }
    
    
    var params: Parameters? {
        switch self {
        case .fetchAccessToken(let accessCode):
            return [
                "client_id": GithubConstants.clientID,
                "client_secret": GithubConstants.clientSecret,
                "code": accessCode!
            ]
        case .fetchUsers(let language, let page):
            return [
                "sort": "stars",
                "orded": "desc",
                "q": language!,
                "page": page!
            ]
        case .fetchRepos(language: let language, page: let page):
            return [
                "sort": "stars",
                "orded": "desc",
                "q": language!,
                "page": page!
            ]
        case .fetchAuthenticatedUser:
            return nil
        case .fetchUserRepos:
            return nil
        case .fetchUserStarred:
            return nil
        case .fetchSpecificUser:
            return nil
        }
    }
    
    var headers: HTTPHeaders? {
        switch self {
        case .fetchAccessToken:
            return ["Accept": "application/json"]
        case .fetchUsers:
            return nil
        case .fetchRepos:
            return nil
        case .fetchAuthenticatedUser:
            let token = UserDefaults.standard.string(forKey: "token")
            return [
                "Accept": "application/vnd.github.v3+json",
                "Authorization": "Bearer \(token!)"
            ]
        case .fetchUserRepos:
            return nil
        case .fetchUserStarred:
            return nil
        case .fetchSpecificUser:
            return nil
        }
    }
    
    
    var encoding: ParameterEncoding {
        switch self {
        case .fetchAccessToken:
            return JSONEncoding.default
        case .fetchUsers:
            return URLEncoding.queryString
        case .fetchRepos:
            return URLEncoding.queryString
        case .fetchAuthenticatedUser:
            return JSONEncoding.default
        case .fetchUserRepos:
            return JSONEncoding.default
        case .fetchUserStarred:
            return JSONEncoding.default
        case .fetchSpecificUser:
            return JSONEncoding.default
        }
    }
    
    
    
    
    
    
}
