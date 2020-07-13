//
//  FlickrAPI.swift
//  MyPhotoApp
//
//  Created by Jody Abney on 7/11/20.
//  Copyright © 2020 AbneyAnalytics. All rights reserved.
//

import Foundation

struct FlickrAPI {
    
    //MARK: - Properties
    private static let baseURLString = "https://api.flickr.com/services/rest"
    private static let apiKey = "eeeb1f70e2b397eaf6283d8bd2e95ddb"
    
    static var interestingPhotosURL: URL {
        return flickrURL(endPoint: .interestingPhotos,
                         parameters: ["extras" : "url_z,date_taken"])
    }
    
    static var recentPhotosURL: URL {
        return flickrURL(endPoint: .recentPhotos,
                         parameters: ["extras" : "url_z,date_taken"])
    }
    
    static var popularPhotosURL: URL {
        return flickrURL(endPoint: .popularPhotos,
                         parameters: ["extras" : "url_z,date_taken"])
    }
    
    
    //MARK: - Methods
    
    private static func flickrURL(endPoint: Constants.EndPoint,
                                  parameters: [String: String]?) -> URL {
        
        var components = URLComponents(string: baseURLString)!
        var queryItems = [URLQueryItem]()
        
        let baseParams = [
            "method": endPoint.rawValue,
            "format": "json",
            "nojsoncallback": "1",
            "api_key": apiKey
        ]
        
        for (key, value) in baseParams {
            let item = URLQueryItem(name: key, value: value)
            queryItems.append(item)
        }
        
        if let additionalParams = parameters {
            for (key, value) in additionalParams {
                let item = URLQueryItem(name: key, value: value)
                queryItems.append(item)
            }
        }
        components.queryItems = queryItems
        
        return components.url!
    }
    
    
    static func photos(fromJSON data: Data) -> Result<[FlickrPhoto], Error> {
        do {
            let decoder = JSONDecoder()
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            
            let flickrResponse = try decoder.decode(FlickrResponse.self, from: data)
            let photos = flickrResponse.photosInfo.photos.filter{ $0.remoteURL != nil }
            return .success(photos)
        } catch {
            return .failure(error)
        }
    }
    
    
}
