//
//  MathPixModel.swift
//  MathProject
//
//  Created by Hakan ERDOĞMUŞ on 30.10.2023.
//

import Foundation

struct MathPixModel : Codable {
    let photoUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case photoUrl
    }
    
    var _photoUrl: String {
        photoUrl ?? ""
    }
}
