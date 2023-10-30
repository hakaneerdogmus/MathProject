//
//  NetworkManager.swift
//  MathProject
//
//  Created by Hakan ERDOĞMUŞ on 30.10.2023.
//

import Alamofire
import Foundation

enum ServiceEndPoint {
    static func mathPixUrl() -> String {
        return ""
    }
}

class NetworkManager {
    static let shared = NetworkManager()
    
    func downloadMathPix(completion: @escaping (MathPixModel?) -> Void) {
        guard let url = URL(string: ServiceEndPoint.mathPixUrl()) else {
            print("DownloadMathPix URL Error")
            return
        }
        AF.request(url).responseDecodable(of: MathPixModel.self) { (model) in
            guard let data = model.value else {
                print("AF.reques Error")
                completion(nil)
                return
            }
            completion(data)
        }
    }
}
