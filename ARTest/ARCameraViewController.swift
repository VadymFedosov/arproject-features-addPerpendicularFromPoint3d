//
//  ARCameraViewController.swift
//  ARTest
//
//  Created by Vadym F on 21.08.2020.
//  Copyright © 2020 Vadym F. All rights reserved.
//

import ARKit

class ARCameraViewController: UIViewController {
    // MARK: - IBOutlet
    @IBOutlet weak var arView: ARCameraView!
    
    // MARK: - Private Properties
    private let configuration: ARWorldTrackingConfiguration = {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        return configuration
    }()
    
    // MARK: - View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
    }
    
    // MARK: - Private Methods
    private func setView() {
        arView.delegate = self
        arView.sceneView.session.run(configuration, options: [])
        arView.sceneView.debugOptions = [.showFeaturePoints]
    }
    
    private func getFeaturesPoints() -> FeaturesPointsData? {
        guard   let points = arView.sceneView.session.currentFrame?.rawFeaturePoints?.points,
                points.count > Constants.ARCamera.minNumbOfFeaturePoints else { return nil }
        
        var pointsArray = [FeaturesPointData]()
        
        for point in points {
            let devicePointsData = arView.sceneView.projectPoint(SCNVector3(point))
            
            let devicePoint = PointData(x: devicePointsData.x,
                                        y: devicePointsData.y,
                                        z: devicePointsData.z)
            
            let arPoint = PointData(x: point.x,
                                    y: point.y,
                                    z: point.z)
            
            let featuresPointData = FeaturesPointData(devicePoint: devicePoint,
                                                      arPoint: arPoint)
            pointsArray.append(featuresPointData)
        }
        
        return FeaturesPointsData(points: pointsArray)
    }
}

// MARK: - ARCameraViewDelegate
extension ARCameraViewController: ARCameraViewDelegate {
    func photoButtonDidTaped() {
        guard let data = getFeaturesPoints() else {
            presentErrorAlert(message: Constants.ARCamera.errorMessage)
            return
        }
        let image = arView.sceneView.snapshot()
        
        let storyboard = UIStoryboard(name: Constants.ARPhoto.storyboardNameAndIdentifire,
                                      bundle: nil)
        
        let vc = storyboard.instantiateInitialViewController() as! ARPhotoViewController
        vc.data = data
        vc.image = image
        
        navigationController?.pushViewController(vc, animated: true)
    }
}
