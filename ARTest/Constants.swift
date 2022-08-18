//
//  Constants.swift
//  ARTest
//
//  Created by Vadym F on 29.08.2020.
//  Copyright © 2020 Vadym F. All rights reserved.
//

import CoreGraphics

struct Constants {
    // MARK: - ARCamera
    struct ARCamera {
        static let minNumbOfFeaturePoints = 100
        static let errorMessage = "Too little data to take a picture. Try to increase the amount of light"
    }
    
    // MARK: - ARPhoto
    struct ARPhoto {
        static let storyboardNameAndIdentifire = "ARPhotoStoryboard"
        static let errorMessage = "We could not find a point on the plane. Try another point please."
        static let maxNumbOfPoints = 2
        static let lineDashPattern = 10
        static let lineWidth: CGFloat = 10
        static let pointRadius: CGFloat = 10
        static let startSearchRectSize: CGFloat = 50
        static let additionSearchRectSize: CGFloat = 30
        static let maxNumbOfSearchRectSizeAddition: CGFloat = 5
    }
    
    // MARK: - UIViewController
    struct UIViewController {
        static let errorTitle = "Error"
        static let errorCancelAction = "Cancel"
    }
    
    // MARK: - ProgressIndicator
    struct ProgressIndicator {
        static let storyboardNameAndIdentifire = "ProgressIndicatorStoryboard"
    }
}
