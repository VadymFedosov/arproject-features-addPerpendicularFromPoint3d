//
//  ARPhotoView.swift
//  ARTest
//
//  Created by Vadym F on 27.08.2020.
//  Copyright © 2020 Vadym F. All rights reserved.
//

import UIKit.UIView

protocol ARPhotoViewDelegate: class {
    func photoDidTaped(in touchesPoint: CGPoint)
}

class ARPhotoView: UIView {
    // MARK: - Public Properties
    weak var delegate: ARPhotoViewDelegate!
    
    // MARK: - Private Properties
    private var sublayers: [CAShapeLayer] = {
        return [CAShapeLayer]()
    }()
    
    // MARK: - IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak private var distanceLabel: UILabel!
    
    // MARK: - Public Methods
    func drawDistance(with first: CGPoint, and second: CGPoint?, distance: Float) {
        guard let second = second else {
            drawPoint(first)
            return
        }
        
        distanceLabel.text = "\(distance) m"
        drawLine(first, second)
        drawPoint(first)
        drawPoint(second)
    }
    
    func removeDistance() {
        distanceLabel.text = "0 m"
        sublayers.forEach { $0.removeFromSuperlayer() }
        sublayers.removeAll()
    }
    
    // MARK: - Private Methods
    private func drawPoint(_ center: CGPoint) {
        let radius: CGFloat = Constants.ARPhoto.pointRadius
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        
        let pointLayer = CAShapeLayer()
        pointLayer.path = path.cgPath
        pointLayer.fillColor = UIColor.red.cgColor
        
        sublayers.append(pointLayer)
        imageView.layer.addSublayer(pointLayer)
    }
    
    private func drawLine(_ first: CGPoint, _ second: CGPoint) {
        drawPoint(first)
        drawPoint(second)
        
        let path = UIBezierPath()
        path.move(to: first)
        path.addLine(to: second)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineDashPattern = [NSNumber(value: Constants.ARPhoto.lineDashPattern * 2),
                                      NSNumber(value: Constants.ARPhoto.lineDashPattern)]
        shapeLayer.lineWidth = Constants.ARPhoto.lineWidth
        
        sublayers.append(shapeLayer)
        imageView.layer.addSublayer(shapeLayer)
    }
    
    // MARK: - Overrides
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touches = touches.first else { return }
        let point = touches.location(in: imageView)
        delegate.photoDidTaped(in: point)
    }
}
