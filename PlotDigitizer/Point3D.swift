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
        if dimension == 0 {
            return self.x
        } else if dimension == 1 {
            return self.y
        } else {
            return self.z
        }
    }
    
    func squaredDistance(to otherPoint: Point3D) -> Double {
        return pow(x - otherPoint.x, 2) + pow(y - otherPoint.y, 2) + pow(z - otherPoint.z, 2)
    }
    
    let x: Double
    let y: Double
    let z: Double
    let value: Double
}
