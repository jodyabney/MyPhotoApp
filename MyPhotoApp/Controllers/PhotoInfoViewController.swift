//
//  PhotoInfoViewController.swift
//  MyPhotoApp
//
//  Created by Jody Abney on 7/11/20.
//  Copyright © 2020 AbneyAnalytics. All rights reserved.
//

import UIKit

class PhotoInfoViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet var imageView: UIImageView!
    
    //MARK: - Properties
    var photo: Photo! {
        didSet {
            navigationItem.title = photo.title
        }
    }
    var store: PhotoStore!
    
    
    //MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        store.fetchImage(for: photo) { (result) -> Void in
            switch result {
            case let .success(image):
                self.imageView.image = image
            case let .failure(error):
                print("Error fetching image for photo: \(error)")
            }
        }
    }
    
    
    //MARK: - Instance <ethods
    
    
    
    //MARK: - IBActions
}
