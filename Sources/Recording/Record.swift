//
//  File.swift
//
//
//  Created by Joel Tan on 30/8/2024.
//

import AppKit
import AVFoundation
import Foundation

class ScreenRecorder: NSObject, AVCaptureFileOutputRecordingDelegate {
  private var session: AVCaptureSession!
  private var output: AVCaptureMovieFileOutput!
  private var isRecording = false
  
  func record_screen() {
    session = AVCaptureSession()

    // Set up the screen input
    if let screen = NSScreen.main {
      let displayId = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as! CGDirectDisplayID
      guard let screenInput = AVCaptureScreenInput(displayID: displayId) else { return }
      screenInput.minFrameDuration = CMTime(value: 1, timescale: 60)
      if session.canAddInput(screenInput) {
        session.addInput(screenInput)
      }
    }

    // Set up the output
    output = AVCaptureMovieFileOutput()
    if session.canAddOutput(output) {
      session.addOutput(output)
    }

    // Start the session
    session.startRunning()

    // Specify output file URL
    let fileManager = FileManager.default
    let cwd = fileManager.currentDirectoryPath
    let outputURL = URL(fileURLWithPath: cwd).appendingPathComponent(makeFileName())

    // Start recording
    isRecording = true
    output.startRecording(to: outputURL, recordingDelegate: self)

    print("Recording started successfully")
    print("Recording to: \(outputURL.path)")
  }
  
  func stopRecording() {
      if isRecording {
          output.stopRecording()
          session.stopRunning()
          isRecording = false
          print("Recording stopped")
      }
  }

  // Delegate methods
  func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
    if let error = error {
      print("Recording failed: \(error.localizedDescription)")
    } else {
      print("Recording finished successfully")
    }
  }
}
