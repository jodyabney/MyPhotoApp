//
//  FlickrPhotosResponse.swift
//  MyPhotoApp
//
//  Created by Jody Abney on 7/11/20.
//  Copyright © 2020 AbneyAnalytics. All rights reserved.
//

import Foundation

struct FlickrPhotosResponse: Codable {
    let photos: [FlickrPhoto]
    
    enum CodingKeys: String, CodingKey {
        case photos = "photo"
    }
}
