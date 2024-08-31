import ArgumentParser
import AVFoundation
import Foundation

@available(macOS 13.0, *)
@main
struct Handlens: AsyncParsableCommand {
    mutating func run() async throws {
        let recorder = ScreenRecorder()
        let monitor = ClickMonitor()

        DispatchQueue.global().async {
            monitor.start()
        }

        var startTime: UInt64 = 0
        guard let recordingURL = recorder.record_screen(onStart: {
            startTime = machTimeToNanoseconds(mach_absolute_time())
        }) else { return }

        print("Press any key to end recording...")
        _ = getch()

        monitor.stop()
        recorder.stopRecording()

        let video = AVAsset(url: recordingURL)
        let videoSize = await getVideoSize(from: video) ?? CGSize(width: 1920, height: 1080)
        let edits = makeEditPoints(clickEvents: monitor.clickEvents, videoSize: videoSize, startTime: startTime, videoDuration: video.duration)

        let outputURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent(makeFileName(prefix: "edited"))

        do {
            let editedVideoURL = try VideoEditor.applyEditsToVideo(inputURL: recordingURL, edits: edits, outputURL: outputURL)
            print("Edited video saved to: \(editedVideoURL.path)")
        } catch {
            print("Error editing video: \(error)")
        }
    }
}
