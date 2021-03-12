//
//  GithubAccessToken.swift
//  git-it
//
//  Created by Marwan Osama on 3/6/21.
//

import Foundation

struct GithubAccessToken: Codable {
  let accessToken: String
  let tokenType: String

  enum CodingKeys: String, CodingKey {
    case accessToken = "access_token"
    case tokenType = "token_type"
  }
}
