//
//  ARCameraView.swift
//  ARTest
//
//  Created by Vadym F on 27.08.2020.
//  Copyright © 2020 Vadym F. All rights reserved.
//

import ARKit

// MARK: - Protocol
protocol ARCameraViewDelegate: class {
    func photoButtonDidTaped()
}

class ARCameraView: UIView {
    // MARK: - Public Properties
    weak var delegate: ARCameraViewDelegate!
    
    // MARK: - IBOutlet
    @IBOutlet weak var sceneView: ARSCNView!
    
    // MARK: - IBAction
    @IBAction func photoButtonAction(_ sender: UIButton) {
        delegate.photoButtonDidTaped()
    }
}
