import AVFoundation
import CoreGraphics
import Foundation

class VideoEditor {

    // MARK: - Public Methods

    static func applyEditsToVideo(inputURL: URL, edits: [ZoomEdit], outputURL: URL) throws -> URL {
        let asset = AVAsset(url: inputURL)
        let composition = try createComposition(from: asset)
        let videoComposition = createVideoComposition(for: composition, asset: asset, edits: edits)

        return try exportVideo(composition: composition, videoComposition: videoComposition, to: outputURL)
    }

    // MARK: - Private Methods

    private static func createComposition(from asset: AVAsset) throws -> AVMutableComposition {
        let composition = AVMutableComposition()

        guard let videoTrack = asset.tracks(withMediaType: .video).first,
              let compositionVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        else {
            throw VideoEditorError.failedToGetVideoTrack
        }

        try compositionVideoTrack.insertTimeRange(CMTimeRange(start: .zero, duration: asset.duration), of: videoTrack, at: .zero)

        return composition
    }

    private static func createVideoComposition(for composition: AVMutableComposition, asset: AVAsset, edits: [ZoomEdit]) -> AVMutableVideoComposition {
        let videoComposition = AVMutableVideoComposition(propertiesOf: asset)
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: asset.duration)

        guard let compositionTrack = composition.tracks(withMediaType: .video).first else {
            fatalError("Failed to get composition video track")
        }

        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionTrack)
        applyZoomEdits(to: layerInstruction, edits: edits, duration: asset.duration, naturalSize: compositionTrack.naturalSize)

        instruction.layerInstructions = [layerInstruction]
        videoComposition.instructions = [instruction]

        return videoComposition
    }

    private static func applyZoomEdits(to layerInstruction: AVMutableVideoCompositionLayerInstruction, edits: [ZoomEdit], duration: CMTime, naturalSize: CGSize) {
        let sortedEdits = edits.sorted { $0.start < $1.start }
        var currentScale: CGFloat = 1.0
        var currentCenter = CGPoint(x: naturalSize.width / 2, y: naturalSize.height / 2)

        for edit in sortedEdits {
            applyZoomEdit(edit, to: layerInstruction, startScale: currentScale, startCenter: currentCenter, naturalSize: naturalSize)
            currentScale = edit.scale
            currentCenter = edit.center
        }

        //// Set final transform for the entire duration
        //if let lastEdit = sortedEdits.last {
        //    let finalTransform = createTransform(scale: lastEdit.scale, center: lastEdit.center, naturalSize: naturalSize)
        //    layerInstruction.setTransform(finalTransform, at: duration)
        //}
    }

    private static func applyZoomEdit(_ edit: ZoomEdit, to layerInstruction: AVMutableVideoCompositionLayerInstruction, startScale: CGFloat, startCenter: CGPoint, naturalSize: CGSize) {
        let transitionDuration = CMTime(seconds: 1, preferredTimescale: 600)
        let keyframeCount = 60

        for j in 0 ... keyframeCount {
            // Calculate the progress (0 to 1) for this keyframe
            let progress = Double(j) / Double(keyframeCount)
            // Apply easing function to the progress for smoother animation
            let easedProgress = easeInOutCubic(progress)
            // Calculate the current time for this keyframe
            let currentTime = edit.start + CMTimeMultiplyByFloat64(transitionDuration, multiplier: progress)

            // Interpolate the scale between the start and end values
            let scale = interpolate(start: startScale, end: edit.scale, progress: easedProgress)
            // Interpolate the center X and Y coordinates
            let centerX = interpolate(start: startCenter.x, end: edit.center.x, progress: easedProgress)
            let centerY = interpolate(start: startCenter.y, end: edit.center.y, progress: easedProgress)

            // Create a new transform with the interpolated values
            let newTransform = createTransform(scale: scale, center: CGPoint(x: centerX, y: centerY), naturalSize: naturalSize)

            // Apply the transform to the layer instruction at the current time
            layerInstruction.setTransform(newTransform, at: currentTime)
        }

        // Set final transform for this edit
        let finalTransform = createTransform(scale: edit.scale, center: edit.center, naturalSize: naturalSize)
        layerInstruction.setTransform(finalTransform, at: edit.start + transitionDuration)
    }

    private static func createTransform(scale: CGFloat, center: CGPoint, naturalSize: CGSize) -> CGAffineTransform {
        let translationX = naturalSize.width / 2 - center.x * scale
        let translationY = naturalSize.height / 2 - center.y * scale
        return CGAffineTransform(translationX: translationX, y: translationY).scaledBy(x: scale, y: scale)
    }

    private static func exportVideo(composition: AVComposition, videoComposition: AVVideoComposition, to outputURL: URL) throws -> URL {
        guard let export = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
            throw VideoEditorError.failedToCreateExportSession
        }

        export.videoComposition = videoComposition
        export.outputURL = outputURL
        export.outputFileType = .mp4

        return try performExport(export)
    }

    private static func performExport(_ export: AVAssetExportSession) throws -> URL {
        // Create a semaphore to synchronize the asynchronous export process
        let exportSemaphore = DispatchSemaphore(value: 0)

        export.exportAsynchronously {
            // Signal the semaphore when the export is complete
            exportSemaphore.signal()
        }

        exportSemaphore.wait()

        if let error = export.error {
            throw error
        }

        // Ensure the export was successful and we have a valid output URL
        guard let outputURL = export.outputURL, export.status == .completed else {
            throw VideoEditorError.exportFailed
        }

        return outputURL
    }

    // MARK: - Helper Functions

    private static func easeInOutCubic(_ x: Double) -> Double {
        return x < 0.5 ? 4 * x * x * x : 1 - pow(-2 * x + 2, 3) / 2
    }

    private static func interpolate(start: CGFloat, end: CGFloat, progress: Double) -> CGFloat {
        return start + CGFloat(progress) * (end - start)
    }
}

// MARK: - Error Handling

enum VideoEditorError: Error {
    case failedToGetVideoTrack
    case failedToCreateExportSession
    case exportFailed
}
