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
    
    // set up the core data references
    static let ad = UIApplication.shared.delegate as! AppDelegate
    static let context = ad.persistentContainer.viewContext
}
