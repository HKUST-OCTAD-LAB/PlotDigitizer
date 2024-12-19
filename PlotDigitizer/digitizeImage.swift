//
//  digitizeImage.swift
//  PlotDigitizer
//
//  Created by James Shihua on 11/12/2024.
//

import CoreImage
import CoreGraphics
import SwiftUI
import AppKit
import KDTree

func digitizeImage(image: NSImage?, corners: [CGPoint], colorbar: [CGPoint], values: [Double]) {
    guard let tiffData = image?.tiffRepresentation,
        let bitmap = NSBitmapImageRep(data: tiffData) else {
        return
    }
    let colormap = interpolateColorbar(bitmap: bitmap, twoPoints: colorbar, twoValues: values)
    let croppedBitmap = cropImage(bitmap: bitmap, corners: corners)
    let values = interpolateColorValue(bitmap: croppedBitmap, colormap: colormap)
    print("Values have been extracted.")
    let fileURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("heatmap.csv")
    print("Try to save to \(fileURL.path).")
    do {
        try saveAsCSV(data: values, to: fileURL.path)
    } catch {
        print("Error saving CSV file!")
    }
}


// The digitize function which will be called when "Digitize" button is pressed
func cropImage(bitmap: NSBitmapImageRep, corners: [CGPoint]) -> NSBitmapImageRep {
//    let displayWidth: Double = Double(image?.size.width ?? 0.0)
//    let displayHeight: Double = Double(image?.size.height ?? 0.0)

    let x0: Int = Int(corners[0].x)
    let y0: Int = Int(corners[0].y)
    let x1: Int = Int(corners[1].x)
    let y1: Int = Int(corners[2].y)
    
    print("==> Subroutine: crop image to bitmap.")
    print("Original size (\(bitmap.pixelsWide), \(bitmap.pixelsHigh))")
    print("X range: [\(x0), \(x1)]")
    print("Y range: [\(y0), \(y1)]")
    
    guard x0 >= 0, x1 <= bitmap.pixelsWide, x0 < x1,
          y0 >= 0, y1 <= bitmap.pixelsHigh, y0 > y1 else {
        print("Invalid crop coordinates")
        return bitmap
    }
    
    let cropRect = CGRect(
        x: x0,
        y: y1,
        width: x1 - x0,
        height: y0 - y1
    )
    
    guard let croppedImage = bitmap.cgImage?.cropping(to: cropRect) else {
        return bitmap
    }
        
    return NSBitmapImageRep(cgImage: croppedImage)
}

struct ColorMap {
    let values: [Double]
    let colors: [NSColor]
}

func interpolateColorbar(bitmap: NSBitmapImageRep, twoPoints: [CGPoint], twoValues: [Double]) -> ColorMap {
    let x = Int((twoPoints[0].x + twoPoints[1].x) / 2)
    let y0: Int = Int(twoPoints[0].y)
    let y1: Int = Int(twoPoints[1].y)
    
    guard 0 <= y1 && y1 < y0 && y0 < bitmap.pixelsHigh else {
        return ColorMap(values: [0,1], colors: [.black, .black])
    }

    print("==> Subroutine: extract colorbar.")
    let k: Double = (twoValues[0] - twoValues[1]) / Double(y0 - y1)
    let values: [Double] = (y1 ... y0).map {
        return twoValues[1] + k * Double($0 - y1)
    }
    let colors: [NSColor] = (y1 ... y0).map {
        let color = bitmap.colorAt(x: x, y: $0)!
//        print("Red: \(color.redComponent), Green: \(color.greenComponent), Blue: \(color.blueComponent)")
        return color
    }
    print("\(values.count) data points are used.")
    
    return ColorMap(values: values, colors: colors)
}

func interpolateColorbar2(bitmap: NSBitmapImageRep, twoPoints: [CGPoint], twoValues: [Double]) -> ColorMap {
    let x = Int((twoPoints[0].x + twoPoints[1].x) / 2)
    let y0: Int = Int(twoPoints[0].y)
    let y1: Int = Int(twoPoints[1].y)
    
    guard 0 <= y1 && y1 < y0 && y0 < bitmap.pixelsHigh else {
        return ColorMap(values: [0,1], colors: [.black, .black])
    }

    print("==> Subroutine: extract colorbar.")
    let k: Double = (twoValues[0] - twoValues[1]) / Double(y0 - y1)
    let values: [Double] = (y1 ... y0).map {
        return twoValues[1] + k * Double($0 - y1)
    }
    let colors: [NSColor] = (y1 ... y0).map {
        let color = bitmap.colorAt(x: x, y: $0)!
//        print("Red: \(color.redComponent), Green: \(color.greenComponent), Blue: \(color.blueComponent)")
        return color
    }
    print("\(values.count) data points are used.")
    
    return ColorMap(values: values, colors: colors)
}


func colorDistance(_ color1: NSColor, _ color2: NSColor) -> Double {
    let redDiff = color1.redComponent - color2.redComponent
    let greenDiff = color1.greenComponent - color2.greenComponent
    let blueDiff = color1.blueComponent - color2.blueComponent

    return sqrt(redDiff * redDiff + greenDiff * greenDiff + blueDiff * blueDiff)
}

func findClosestColorValue(colormap: ColorMap, target: NSColor?) -> Double? {
//    guard colors.count == values.count, !colors.isEmpty, ((target?.redComponent) != nil) else {
//        print("Error: Colors and values must have the same non-zero length.")
//        return nil
//    }
//    var closestColor: NSColor
    var closestValue = nil as Double?
    var smallestDistance = Double.infinity

    for (index, color) in colormap.colors.enumerated() {
        let distance = colorDistance(color, target!)
        if distance < smallestDistance {
            smallestDistance = distance
//            closestColor = color
            closestValue = colormap.values[index]
        }
    }
    
    return closestValue
}

func interpolateColorValue(bitmap: NSBitmapImageRep, colormap: ColorMap) -> [[Double]] {
    let width = bitmap.pixelsWide
    let height = bitmap.pixelsHigh
    var values: [[Double]] = Array(repeating: Array(repeating: 0, count: width), count: height)
    
    print("==> Subroutine: interpolate colors to values.")
    for y in 0..<height {
        for x in 0..<width {
            let color = bitmap.colorAt(x: x, y: y)
            values[y][x] = findClosestColorValue(colormap: colormap, target: color) ?? 0
        }
        if (y % max(height / 100, 1) == 0) {
            print("Progress: \(y) / \(height)...")
        }
    }
    
    return values
}

func saveAsCSV(data: [[Double]], to filePath: String) throws {
    // Step 1: Convert 2D array into CSV format
    let csvString = data.map { row in
        row.map { String($0) }.joined(separator: ",") // Join elements in a row with commas
    }.joined(separator: "\n") // Join rows with newlines

    // Step 2: Write the CSV string to the specified file path
    try csvString.write(toFile: filePath, atomically: true, encoding: .utf8)
}

