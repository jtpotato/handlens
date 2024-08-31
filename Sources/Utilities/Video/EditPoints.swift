//
//  EditPoints.swift
//
//
//  Created by Joel Tan on 31/8/2024.
//

import AVFoundation
import CoreGraphics
import Foundation

struct ZoomEdit {
    var start: CMTime
    var center: CGPoint
    var scale: CGFloat
}

/// This function takes in click events and creates a series of edits to make.
func makeEditPoints(clickEvents: [ClickEvent], videoSize: CGSize, startTime: UInt64, videoDuration _: CMTime) -> [ZoomEdit] {
    guard !clickEvents.isEmpty else { return [] }

    let zoomInDuration = CMTime(seconds: 1, preferredTimescale: 600)
    let zoomDuration = CMTime(seconds: 1, preferredTimescale: 600)
    let zoomOutDuration = CMTime(seconds: 1, preferredTimescale: 600)
    let zoomScale = CGFloat(1.5)
    let normalScale = CGFloat(1.0)
    let centerPoint = CGPoint(x: videoSize.width / 2, y: videoSize.height / 2)
    let minClickDistance = CGFloat(100)

    // super jank
    let correctionTime = CMTime(seconds: 0.5, preferredTimescale: 1_000_000_000)

    var zoomEdits: [ZoomEdit] = []

    for i in 0 ..< clickEvents.count {
        let currentClick = clickEvents[i]
        print((currentClick.time - startTime) / 1_000_000)
        let currentTime = CMTime(value: Int64(currentClick.time - startTime), timescale: 1_000_000_000) - correctionTime

        // Zoom in before the click
        // but only if there's enough time before the click
        if i > 0 {
            let previousClick = clickEvents[i - 1]
            let previousTime = CMTime(value: Int64(previousClick.time - startTime), timescale: 1_000_000_000) - correctionTime
            let timeSincePreviousClick = currentTime - previousTime

            if timeSincePreviousClick > zoomDuration + zoomOutDuration + zoomInDuration + zoomDuration {
                // If there's enough time, zoom in to the click
                let zoomInStartTime = currentTime - zoomDuration
                zoomEdits.append(ZoomEdit(start: zoomInStartTime, center: currentClick.location, scale: zoomScale))
            }
        } else {
            // For the first click, always zoom in to the click
            let zoomInStartTime = currentTime - zoomDuration
            zoomEdits.append(ZoomEdit(start: zoomInStartTime, center: currentClick.location, scale: zoomScale))
        }

        // Zoom out after the click
        let zoomOutStartTime = currentTime + zoomDuration

        if i < clickEvents.count - 1 {
            let nextClick = clickEvents[i + 1]
            let nextTime = CMTime(value: Int64(nextClick.time - startTime), timescale: 1_000_000_000) - correctionTime
            let timeToNextClick = nextTime - currentTime

            if timeToNextClick > zoomDuration + zoomOutDuration + zoomInDuration {
                // If there's enough time, zoom out to normal view
                zoomEdits.append(ZoomEdit(start: zoomOutStartTime, center: centerPoint, scale: normalScale))
            } else {
                // If there's not enough time for the full animation, pan to the next click. Only do this if the distance is large enough

                let distance = sqrt(pow(nextClick.location.x - currentClick.location.x, 2) + pow(nextClick.location.y - currentClick.location.y, 2))

                if distance < minClickDistance { continue }
                zoomEdits.append(ZoomEdit(start: zoomOutStartTime - zoomDuration, center: nextClick.location, scale: zoomScale))
            }
        } else {
            // For the last click, always zoom out to normal view
            zoomEdits.append(ZoomEdit(start: zoomOutStartTime, center: centerPoint, scale: normalScale))
        }
    }

    return zoomEdits
}
