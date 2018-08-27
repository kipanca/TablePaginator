//
//  API.swift
//  Aggregation
//
//  Created by Alex Kisel on 8/21/18.
//  Copyright © 2018 BRANDER. All rights reserved.
//

import Foundation
import Alamofire

class API {
  
  static func getUsers(page: Int, pageSize: Int, onComplete: @escaping (([User]?, Error?) -> Void)) {
    
    Alamofire.request("https://randomuser.me/api?results=\(pageSize)&page=\(page)").responseJSON { response in
      if response.result.error != nil {
        onComplete(nil, response.result.error)
        return
      }
      guard let response = response.result.value as? [String: Any],
            var results = response["results"] as? [[String: Any]] else {
        onComplete(nil, nil)
        return
      }
      var users = [User]()
      if page >= 5 { results = Array(results[0..<results.count - 2]) }
      for result in results {
        let user = User()
        user.name = (result["name"] as? [String: Any])?["first"] as? String
        users.append(user)
      }
      onComplete(users, nil)
    }
  }
}
