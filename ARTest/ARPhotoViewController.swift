//
//  ARPhotoViewController.swift
//  ARTest
//
//  Created by Vadym F on 25.08.2020.
//  Copyright © 2020 Vadym F. All rights reserved.
//

import UIKit.UIViewController

// MARK: - Typealias
typealias TrianglePoints = (a: PointData, b: PointData, c: PointData, a3D: PointData, b3D: PointData, c3D: PointData)
typealias TouchData = (point2D: CGPoint, point3D: PointData)

class ARPhotoViewController: UIViewController {
    // MARK: - Public Properties
    var image: UIImage!
    var data: FeaturesPointsData!
    
    // MARK: - Private Properties
    private var model: ARPhotoModel!
    private var points: [TouchData] = {
        return [TouchData]()
    }()
    
    // MARK: - IBOutlets
    @IBOutlet weak private var photoView: ARPhotoView!
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        setModel()
    }
    
    // MARK: - Private Methods
    /// - Tag: Set View
    private func setView() {
        guard let image = image else { return }
        photoView.imageView.image = image
        photoView.delegate = self
    }
    
    private func setModel() {
        guard let data = data else { return }
        model = ARPhotoModel(with: data)
    }
}

// MARK: - ARPhotoViewDelegate
extension ARPhotoViewController: ARPhotoViewDelegate {
    func photoDidTaped(in touchesPoint: CGPoint) {
        guard points.count < 2 else {
            points.removeAll()
            photoView.removeDistance()
            return
        }
        
        presentProgressIndicator()
        
        guard let touchesPointIn3D = model.getTouchesPointIn3D(touchesPoint) else {
            hideProgressIndicator {
                self.presentErrorAlert(message: Constants.ARPhoto.errorMessage)
            }
            
            return
        }
        
        let touchData = (point2D: touchesPoint, point3D: touchesPointIn3D)
        points.append(touchData)
        
        guard   points.count == Constants.ARPhoto.maxNumbOfPoints,
                let firstPoint = points.first,
                let secondPoint = points.last else {
                    
            hideProgressIndicator {
                self.photoView.drawDistance(with: self.points.first!.point2D, and: nil, distance: 0)
            }
            
            return
        }
        
        var distance = model.getDistanceBetween3DPoints(firstPoint.point3D, secondPoint.point3D)
        distance = round(distance * 100) * 0.01
        
        hideProgressIndicator {
            self.photoView.drawDistance(with: firstPoint.point2D, and: secondPoint.point2D, distance: distance)
        }
    }
}
