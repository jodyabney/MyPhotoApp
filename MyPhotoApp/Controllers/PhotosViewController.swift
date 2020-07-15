//
//  ViewController.swift
//  MyPhotoApp
//
//  Created by Jody Abney on 7/11/20.
//  Copyright © 2020 AbneyAnalytics. All rights reserved.
//

import UIKit

class PhotosViewController:  UIViewController, UICollectionViewDelegate {

    //MARK: - IBOutlets
    @IBOutlet var collectionView: UICollectionView!
    
    //MARK: - Properties
    
    var store: PhotoStore!
    let photoDataSource = PhotoDataSource()
    
    
    
    //MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = photoDataSource
        collectionView.delegate = self
        
        // make saved photos visible before refreshing from Flickr
        updateDataSource(urlType: Constants.URLType.interestingPhotos.rawValue)
        
        // refresh interesting photos from Flickr   
        store.fetchPhotos(flickrURL: FlickrAPI.interestingPhotosURL) {
            (photosResult) in
            self.updateDataSource(urlType: Constants.URLType.interestingPhotos.rawValue)
        }
    }
    
    
    //MARK: - Instance Methods
    
    
    
    //MARK: - IBActions
    
    @IBAction func photoSegmentChanged(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0: // Interestingness
            store.fetchPhotos(flickrURL: FlickrAPI.interestingPhotosURL) {
                (photosResult) in
                self.updateDataSource(urlType: Constants.URLType.interestingPhotos.rawValue)
            }
            sender.selectedSegmentIndex = 0
        case 1: // Popular
            store.fetchPhotos(flickrURL: FlickrAPI.popularPhotosURL) {
                (photosResult) in
                self.updateDataSource(urlType: Constants.URLType.popularPhotos.rawValue)
            }
            sender.selectedSegmentIndex = 1
        case 2: // Recent
            store.fetchPhotos(flickrURL: FlickrAPI.recentPhotosURL) {
                (photosResult) in
                self.updateDataSource(urlType: Constants.URLType.recentPhotos.rawValue)
            }
            sender.selectedSegmentIndex = 2
        default:
            break
        }
    }
    
    //MARK: - UICollectionView Delegate Methods
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        let photo = photoDataSource.photos[indexPath.row]
        
        // Dowload the image data, which could take some time
        store.fetchImage(for: photo) { (result) in
            
            // The index path for the photo might have changed between the
            // time the request started and finished, so find the most
            // recent index path
            guard let photoIndex = self.photoDataSource.photos.firstIndex(of: photo),
                case let .success(image) = result else {
                    return
            }
            let photoIndexPath = IndexPath(item: photoIndex, section: 0)
            
            // When the request finishes, find the current cell for this photo
            if let cell = self.collectionView.cellForItem(at: photoIndexPath) as? PhotoCollectionViewCell {
                cell.update(displaying: image)
            }
        }
    }
    
    //MARK: - Navgiation Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Constants.Segue.showPhoto.rawValue:
            if let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first {
                
                let photo = photoDataSource.photos[selectedIndexPath.row]
                
                let destinationVC = segue.destination as! PhotoInfoViewController
                destinationVC.photo = photo
                destinationVC.store = store
            }
        default:
            preconditionFailure("Unexpected segue identifier.")
        }
    }


}

//MARK: - Core Data Methods

extension PhotosViewController {
    private func updateDataSource(urlType: String) {
        store.fetchAllPhotos(urlType: urlType) { (photosResult) in
            
            switch photosResult {
            case let .success(photos):
                self.photoDataSource.photos = photos
            case .failure:
                self.photoDataSource.photos.removeAll()
            }
            self.collectionView.reloadSections(IndexSet(integer: 0))
        }
    }
}
