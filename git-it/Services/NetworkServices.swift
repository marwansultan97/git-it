//
//  NetworkServices.swift
//  git-it
//
//  Created by Marwan Osama on 3/6/21.
//

import Foundation
import Alamofire

class NetworkServices {
    
    static let shared = NetworkServices()
    
    func getData<T:Codable>(url: String,
                            method: HTTPMethod,
                            headers: HTTPHeaders?,
                            parameters: Parameters?,
                            encoding: ParameterEncoding,
                            completion: @escaping(T?, Error?)-> Void) {
        
        Alamofire.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers).responseJSON { (response) in
            switch response.result {
            
            case .failure(let err):
                completion(nil,err)
                
            case .success(_):
                guard let data = response.data else { return }
                do {
                    let dataResult = try JSONDecoder().decode(T.self, from: data)
                    completion(dataResult,nil)
                } catch let jsonErr {
                    completion(nil,jsonErr)
                }
            }
        }
        
    }
    
    
    
}
