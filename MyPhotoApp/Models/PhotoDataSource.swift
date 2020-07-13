//
//  PhotoDataSource.swift
//  MyPhotoApp
//
//  Created by Jody Abney on 7/11/20.
//  Copyright © 2020 AbneyAnalytics. All rights reserved.
//

import UIKit

class PhotoDataSource: NSObject, UICollectionViewDataSource {
    
    //MARK: - Properties
    var photos = [Photo]()
    
    
    //MARK: - UIColelctionView DataSource Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let identifier = "PhotoCollectionViewCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier,
                                                      for: indexPath) as! PhotoCollectionViewCell
        cell.update(displaying: nil)
        return cell
    }
    
    
    
}
