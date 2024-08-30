import ArgumentParser
import Foundation

@available(macOS 13.0, *)
@main
struct Handlens: AsyncParsableCommand {
  mutating func run() async throws {
    let recorder = ScreenRecorder()
    recorder.record_screen()
    print("Press any key to end recording...")
    _ = getch()
    sleep(1)
    print("Recording stopped. Editing...")
  }
}
