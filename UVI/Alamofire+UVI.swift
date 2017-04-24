//
//  Alamofire+UVI.swift
//  UVI
//
//  Created by Shane Qi on 4/23/17.
//  Copyright © 2017 Transformers. All rights reserved.
//

//http://api.voicerss.org/?key=b3ec3f8ce2804ecca65a6c1f85de87df&src=Helloworld!

import Alamofire
import Foundation

func data(of text: String, completion: @escaping ((Data) -> Void)) {
	Alamofire.request("http://api.voicerss.org/?key=b3ec3f8ce2804ecca65a6c1f85de87df",
	                  method: .post,
	                  parameters: ["src": text],
	                  encoding: URLEncoding.default)
		.responseData { response in
			switch response.result {
			case .success(let data):
				completion(data)
			default:
				break
			}
	}
}
