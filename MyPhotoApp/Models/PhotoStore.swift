//
//  PhotoStore.swift
//  MyPhotoApp
//
//  Created by Jody Abney on 7/11/20.
//  Copyright © 2020 AbneyAnalytics. All rights reserved.
//

import UIKit
import CoreData

enum PhotoError: Error {
    case imageCreationError
    case missingImageURL
}

class PhotoStore {
    
    //MARK: - Properties
    
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    let imageStore = ImageStore()
    
    var urlType: String = Constants.URLType.interestingPhotos.rawValue
    
    
    //MARK: - Methods
    
    func fetchPhotos(flickrURL: URL,
                     completion: @escaping (Result<[Photo], Error>) -> Void) {
        
        switch flickrURL {
        case FlickrAPI.interestingPhotosURL:
            urlType = Constants.URLType.interestingPhotos.rawValue
        case FlickrAPI.popularPhotosURL:
            urlType = Constants.URLType.popularPhotos.rawValue
        case FlickrAPI.recentPhotosURL:
            urlType = Constants.URLType.recentPhotos.rawValue
        default:
            break
        }
        
        let url = flickrURL
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) {
            (data, response, error) in
            
            var result = self.processPhotosRequest(data: data, error: error)
            if case .success = result {
                do {
                    try Constants.context.save()
                } catch {
                    result = .failure(error)
                }
            }
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        task.resume()
    }
    
    
    private func processPhotosRequest(data: Data?,
                                      error: Error?) -> Result<[Photo], Error> {
        guard let jsonData = data else {
            return .failure(error!)
        }
        
        switch FlickrAPI.photos(fromJSON: jsonData) {
        case let .success(flickrPhotos):
            let photos = flickrPhotos.map { flickrPhoto -> Photo in
                
                let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
                let predicate = NSPredicate(format: "\(#keyPath(Photo.photoID)) == \(flickrPhoto.photoID)"
                )
                fetchRequest.predicate = predicate
                var fetchedPhotos: [Photo]?
                Constants.context.performAndWait {
                    fetchedPhotos = try? fetchRequest.execute()
                }
                if let existingPhoto = fetchedPhotos?.first {
                    if existingPhoto.urlType == urlType {
                        return existingPhoto
                    }
                }
                
                var photo: Photo!
                Constants.context.performAndWait {
                    photo = Photo(context: Constants.context)
                    photo.title = flickrPhoto.title
                    photo.photoID = flickrPhoto.photoID
                    photo.remoteURL = flickrPhoto.remoteURL
                    photo.dateTaken = flickrPhoto.dateTaken
                    photo.urlType = self.urlType
                }
                return photo
            }
            return .success(photos)
        case let .failure(error):
            return .failure(error)
        }
    }
    
    func fetchImage(for photo: Photo,
                    completion: @escaping (Result<UIImage, Error>) -> Void) {
        
        guard let photoKey = photo.photoID else {
            preconditionFailure("Photo expected to have a photoID.")
        }
        if let image = imageStore.image(forKey: photoKey) {
            OperationQueue.main.addOperation {
                completion(.success(image))
            }
            return
        }
        
        guard let photoURL = photo.remoteURL else {
            completion(.failure(PhotoError.missingImageURL))
            return
        }
        let request = URLRequest(url: photoURL)
        
        let task = session.dataTask(with: request) {
            (data, response, error) in
            
            let result = self.processImageRequest(data: data, error: error)
            
            if case let .success(image) = result {
                self.imageStore.setImage(image, forKey: photoKey)
            }
            
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        task.resume()
    }
    
    private func processImageRequest(data: Data?,
                                     error: Error?) -> Result<UIImage, Error> {
        guard
            let imageData = data,
            let image = UIImage(data: imageData) else {
                
                // Couldn't create an image
                if data == nil {
                    return .failure(error!)
                } else {
                    return .failure(PhotoError.imageCreationError)
                }
        }
        
        return .success(image)
    }
    
}

extension PhotoStore {
    
    func fetchAllPhotos(urlType: String, completion: @escaping (Result<[Photo], Error>) -> Void) {
        
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let sortByDateTaken = NSSortDescriptor(key: #keyPath(Photo.dateTaken), ascending: true)
        fetchRequest.sortDescriptors = [sortByDateTaken]
        
        Constants.context.perform {
            do {
                let allPhotos = try Constants.context.fetch(fetchRequest)
                let filteredPhotos = allPhotos.filter { (photo) -> Bool in
                    return photo.urlType == self.urlType
                }
                completion(.success(filteredPhotos))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
