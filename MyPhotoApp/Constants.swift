//
//  Constants.swift
//  MyPhotoApp
//
//  Created by Jody Abney on 7/12/20.
//  Copyright © 2020 AbneyAnalytics. All rights reserved.
//

import UIKit
import CoreData

enum Constants {
    
    enum EndPoint: String {
        case interestingPhotos = "flickr.interestingness.getList"
        case recentPhotos = "flickr.photos.getRecent"
        case popularPhotos = "flickr.photos.getPopular"
    }
    
    enum Segue: String {
        case showPhoto = "SegueShowPhoto"
    }
    
    enum SupplementaryElement: String {
        case collectionSectionHeader = "PhotoCollectionHeaderView"
    }
    
    enum URLType: String {
        case interestingPhotos = "interestingness"
        case popularPhotos = "popular"
        case recentPhotos = "recent"
    }
    
    // set up the core data references
    static let ad = UIApplication.shared.delegate as! AppDelegate
    static let context = ad.persistentContainer.viewContext
}
