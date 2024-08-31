import AVFoundation

@available(macOS 12.0, *)
func getVideoSize(from asset: AVAsset) async -> CGSize? {
    guard let videoTrack = try? await asset.loadTracks(withMediaType: .video).first,
          let size = try? await videoTrack.load(.naturalSize)
    else {
        print("Error: Could not determine video size")
        return nil
    }
    return size
}
