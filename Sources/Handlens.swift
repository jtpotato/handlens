import ArgumentParser
import Foundation

@available(macOS 13.0, *)
@main
struct Handlens: AsyncParsableCommand {
  mutating func run() async throws {
    // Init
    let recorder = ScreenRecorder()
    let monitor = ClickMonitor()
    
    // Begin recording
    recorder.record_screen()
    DispatchQueue.global().async {
      monitor.start()
    }
    print("Press any key to end recording...")
    
    // Wait for recording to finish
    _ = getch()
    monitor.stop()
    recorder.stopRecording()
    print(monitor.clickEvents)
    
    print("[LOG] Recording stopped. Editing...")
  }
}
