//
//  ARPhotoModel.swift
//  ARTest
//
//  Created by Vadym F on 27.08.2020.
//  Copyright © 2020 Vadym F. All rights reserved.
//

import UIKit
import Accelerate

class ARPhotoModel {
    // MARK: - Private Properties
    private let data: FeaturesPointsData
    private var searchSquare: CGRect!
    
    // MARK: - Init
    init(with data: FeaturesPointsData) {
        self.data = data
    }
    
    // MARK: - Public Methods
    /// - Tag: Get Touches Point in 3D
    func getTouchesPointIn3D(_ touchesPoint: CGPoint) -> PointData? {
        /// Search Triangle Points
        guard let points = getNeededPoints(touchesPoint) else {
            searchSquare = nil
            return nil
        }
        
        searchSquare = nil
        let pointA = CGPoint(x: CGFloat(points.a.x), y: CGFloat(points.a.y))
        let pointB = CGPoint(x: CGFloat(points.b.x), y: CGFloat(points.b.y))
        let pointC = CGPoint(x: CGFloat(points.c.x), y: CGFloat(points.c.y))
        
        /// Get Ratio
        let acRatio = getRatio(pointA, pointC, center: touchesPoint)
        let bcRatio = getRatio(pointB, pointC, center: touchesPoint)
        
        /// Search 3D Intersection Points
        let ac3DIntersectionPoint = get3dIntersectionPoint(points.a3D, points.c3D, ratio: acRatio) // D
        let bc3DIntersectionPoint = get3dIntersectionPoint(points.b3D, points.c3D, ratio: bcRatio) // E
        
        return getPerpendicularPoint3D(ac3DIntersectionPoint, points.c3D, bc3DIntersectionPoint, points.b3D)
    }
    
    /// - Tag: Get Distance Between 3D Points
    func getDistanceBetween3DPoints(_ a: PointData, _ b: PointData) -> Float {
        let firstMultiplier = pow((b.x - a.x), 2)
        let secondMultiplier = pow((b.y - a.y), 2)
        let thirdMultiplier = pow((b.z - a.z), 2)
        
        return sqrt(firstMultiplier + secondMultiplier + thirdMultiplier)
    }
    
    // MARK: - Private Methods
    /// - Tag: Search Needed Triangle Points
    private func getNeededPoints(_ point: CGPoint) -> TrianglePoints? {
        var points = [FeaturesPointData]()
        
        /// Create Search Square
        if searchSquare == nil {
            setSearchSquare(size: Constants.ARPhoto.startSearchRectSize,
                            touchesPoint: point)
        }
        
        /// Search Points In Square
        while true {
            for pointsData in data.points {
                let testPoint = CGPoint(x: CGFloat(pointsData.devicePoint.x),
                                        y: CGFloat(pointsData.devicePoint.y))
                
                guard searchSquare.contains(testPoint) else { continue }
                points.append(pointsData)
            }
            
            if points.count < 3 {
                setSearchSquare(size: searchSquare.width + Constants.ARPhoto.additionSearchRectSize,
                                touchesPoint: point)
                
                points = [FeaturesPointData]()
                
            } else {
                break
            }
        }
        
        /// Check the Points, If Not Found, Start the Function Again
        guard let returnedPoints = pointCheck(with: point, points) else {
            let size = searchSquare.width + Constants.ARPhoto.additionSearchRectSize
            
            guard size <= Constants.ARPhoto.startSearchRectSize + (Constants.ARPhoto.additionSearchRectSize * Constants.ARPhoto.maxNumbOfSearchRectSizeAddition) else {
                return nil
            }
            
            setSearchSquare(size: size, touchesPoint: point)
            return getNeededPoints(point)
        }
        
        return returnedPoints
    }
    
    /// - Tag: Checking If the Touch Point Belongs to a Triangle
    private func pointCheck(with center: CGPoint, _ points: [FeaturesPointData]) -> TrianglePoints? {
        /// Get All Triangle Points Combination
        let allCombinations = combinations(array: points)
        
        /// Search Needed Combination
        for combinations in allCombinations {
            let trianglePoints = TrianglePoints(a: combinations[0].devicePoint,
                                                b: combinations[1].devicePoint,
                                                c: combinations[2].devicePoint,
                                                a3D: combinations[0].arPoint,
                                                b3D: combinations[1].arPoint,
                                                c3D: combinations[2].arPoint)
            
            let aFirstMultiplier = (trianglePoints.a.x - Float(center.x)) * (trianglePoints.b.y - trianglePoints.a.y)
            let aSecondMultiplier = (trianglePoints.b.x - trianglePoints.a.x) * (trianglePoints.a.y - Float(center.y))
            let a = aFirstMultiplier - aSecondMultiplier
            
            let bFirstMultiplier = (trianglePoints.b.x - Float(center.x)) * (trianglePoints.c.y - trianglePoints.b.y)
            let bSecondMultiplier = (trianglePoints.c.x - trianglePoints.b.x) * (trianglePoints.b.y - Float(center.y))
            let b = bFirstMultiplier - bSecondMultiplier
            
            let cFirstMultiplier = (trianglePoints.c.x - Float(center.x)) * (trianglePoints.a.y - trianglePoints.c.y)
            let cSecondMultiplier = (trianglePoints.a.x - trianglePoints.c.x) * (trianglePoints.c.y - Float(center.y))
            let c = cFirstMultiplier - cSecondMultiplier
            
            guard (a > 0 && b > 0 && c > 0) || (a < 0 && b < 0 && c < 0) else { continue }
            
            return trianglePoints
        }
        
        return nil
    }
    
    /// - Tag: Ratio
    private func getRatio(_ firstPoint: CGPoint, _ secondPoint: CGPoint, center: CGPoint) -> Float {
        let perpendicularPoint = getPerpendicularPoint(firstPoint, secondPoint, center: center)
        
        let abSegmentLength = firstPoint.distance(to: secondPoint)
        let adSegmentLength = firstPoint.distance(to: perpendicularPoint)
        let adPercent = (adSegmentLength / abSegmentLength) * 100
        let dbPercent = 100 - adPercent
        
        var ratio = CGFloat()
        
        if adPercent > dbPercent {
            ratio = dbPercent/adPercent
            
        } else {
            ratio = adPercent/dbPercent
        }
        
        return Float(ratio)
    }
    
    /// - Tag: Get Perpendicular Point
    private func getPerpendicularPoint(_ a: CGPoint, _ b: CGPoint, center: CGPoint) -> CGPoint {
        let x1 = a.x, y1 = a.y,
            x2 = b.x, y2 = b.y,
            x3 = center.x, y3 = center.y
        
        let pX = x2 - x1,
            pY = y2 - y1,
            dP1P2 = (pX * pX) + (pY * pY)
        
        let u = ((x3 - x1) * pX + (y3 - y1) * pY) / dP1P2
        let x = x1 + u * pX,
            y = y1 + u * pY
        
        return CGPoint(x: x, y: y)
    }
    
    /// - Tag: Get Intersection Point in 3D
    private func get3dIntersectionPoint(_ firstPoint: PointData, _ secondPoint: PointData, ratio: Float) -> PointData {
        let x = (firstPoint.x + ratio * secondPoint.x) / (1 + ratio)
        let y = (firstPoint.y + ratio * secondPoint.y) / (1 + ratio)
        let z = (firstPoint.z + ratio * secondPoint.z) / (1 + ratio)
        
        return PointData(x: x, y: y, z: z)
    }
    
    /// - Tag: Get Perpendicular Point in 3D
    private func getPerpendicularPoint3D(_ d: PointData, _ c: PointData, _ e: PointData, _ b: PointData) -> PointData {
        let y = (d.y + c.y + e.y + b.y) * 0.25
        let firstTopMultiplier = c.x - d.x
        let secondTopMultiplier = c.z - d.z
        let thirdTopMultiplier = d.x * (c.x - d.x) + d.z * (c.z - d.z)

        let firstBottomMultiplier = b.x - e.x
        let secondBottomMultiplier = b.z - e.z
        let thirdBottomMultiplier = e.x * (b.x - e.x) + e.z * (b.z - e.z)
        
        let matrix = [[Double(firstTopMultiplier), Double(secondTopMultiplier)],
                      [Double(firstBottomMultiplier), Double(secondBottomMultiplier)]]
        
        let vector = [Double(thirdTopMultiplier), Double(thirdBottomMultiplier)]
        
        let result = solveSystemOfEquations(matrix: matrix, vector: vector)
        
        guard   let x = result.first,
                let z = result.last else { fatalError() }
        
        return PointData(x: Float(x), y: y, z: Float(z))
    }
    
    /// - Tag: Solving a Linear Equation
    private func solveSystemOfEquations(matrix: [[Double]], vector:[Double]) -> [Double] {
        let flatMatrix = Array(matrix.joined())
        let laMatrix: la_object_t =
            la_matrix_from_double_buffer(flatMatrix,  la_count_t(matrix.count),  la_count_t(matrix[0].count),  la_count_t(matrix[0].count), la_hint_t(LA_NO_HINT), la_attribute_t(LA_DEFAULT_ATTRIBUTES))
        let laVector = la_matrix_from_double_buffer(vector, la_count_t(vector.count), 1, 1, la_hint_t(LA_NO_HINT), la_attribute_t(LA_DEFAULT_ATTRIBUTES))
        let vecCj = la_solve(laMatrix, laVector)
        var result: [Double] = Array(repeating: 0.0, count: matrix.count)
        let status = la_matrix_to_double_buffer(&result, 1, vecCj)
        
        if status == la_status_t(LA_SUCCESS) {
            return result
        } else {
            return [Double]()
        }
    }
    
    /// - Tag: Get All Combinations Without Dublicate
    private func combinations<T>(array: [T], size: Int = 3) -> [[T]] {
        if (size > array.count || size == 0 || array.count == 0) {
            return []
        }
      
        if (size == array.count) {
            return [array]
        }
      
        var combs: [[T]] = []
      
        if (size == 1) {
            for item in array {
                combs.append([item])
            }
        
            return combs
        }
      
        for i in 0...(array.count-size) {
            let tails = combinations(array: Array(array[(i + 1)..<array.endIndex]), size: size - 1)
            for tail in tails {
                let element = [array[i]] + tail
                combs.append(element)
            }
        }
      
        return combs
    }
    
    /// - Tag: Set Search Square
    private func setSearchSquare(size: CGFloat, touchesPoint: CGPoint) {
        let origin = CGPoint(x: (touchesPoint.x - size * 0.5), y: (touchesPoint.y - size * 0.5))
        searchSquare = CGRect(origin: origin, size: CGSize(width: size, height: size))
    }
}
