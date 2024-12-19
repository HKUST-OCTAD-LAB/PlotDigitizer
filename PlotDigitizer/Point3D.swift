//
//  Point3D.swift
//  PlotDigitizer
//
//  Created by James Shihua on 19/12/2024.
//
import Foundation
import KDTree

struct Point3D: KDTreePoint {
    static var dimensions: Int = 3
    
    func kdDimension(_ dimension: Int) -> Double {
        <#code#>
    }
    
    let x: Double
    let y: Double
    let z: Double
    let value: Double // The associated value with the point

    // KDTreePoint protocol requires a `dimensions` property to describe the point's coordinates
    static var dimensions: [Double] {
        return [x, y, z]
    }
    
    // Euclidean distance calculation between two points
    func squaredDistance(to otherPoint: Point3D) -> Double {
        return pow(x - otherPoint.x, 2) + pow(y - otherPoint.y, 2) + pow(z - otherPoint.z, 2)
    }
}
