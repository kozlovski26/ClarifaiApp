//
//  Network.swift
//  ClarifaiApp
//
//  Created by Bar kozlovski on 29/05/2019.
//  Copyright © 2019 Bar kozlovski. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON



struct ImageObj: Codable {
    
    let base64: String }


struct DataObj: Codable {
    let image: ImageObj
}


struct InputObj: Codable {
    let data: DataObj
}

struct InputsContainerObj: Codable {
    let inputs: [InputObj]
}


class Network {
    
    let urlObj = URL(string: "https://api.clarifai.com/v2/models/c0c0ac362b03416da06ab3fa36fb58e3/outputs")
    
    
    let headers: HTTPHeaders = [
        "Authorization": "Key d24b022527174a71be94be965e722d1a",
        "Content-Type": "application/json"
    ]
    
    
    
    
    
    
    
    
    
    
    
    
    
    
//
//        let parameters  =   [
//            "inputs": [
//                [
//                    "data": [
//                        "image": [
//                            "url": "https://samples.clarifai.com/demographics.jpg"
//                        ]
//                    ]
//                ]
//            ]]

    
}


