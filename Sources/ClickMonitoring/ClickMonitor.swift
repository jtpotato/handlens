//
//  File.swift
//
//
//  Created by Joel Tan on 30/8/2024.
//

import CoreGraphics
import Foundation

class ClickMonitor {
  private var eventTap: CFMachPort?
  private var runLoopSource: CFRunLoopSource?
  
  private var startTime: Int64?
  var clickEvents: [ClickEvent] = []

  private static var current: ClickMonitor?

  // Define a callback function to handle mouse events
  private var eventCallback: CGEventTapCallBack = { _, type, event, _ in
    guard let monitor = current else { return Unmanaged.passUnretained(event) }

    if type == .leftMouseDown {
      monitor.callback(event: event)
    }
    return Unmanaged.passUnretained(event)
  }

  init() {
    ClickMonitor.current = self
  }

  func callback(event: CGEvent) {
    guard let startTime = startTime else { return }
    
    clickEvents.append(ClickEvent(location: event.location, time: Int64(event.timestamp / 1_000_000) - startTime))
  }

  // Start monitoring mouse events
  func start() {
    let eventMask: CGEventMask = (1 << CGEventType.leftMouseDown.rawValue) | (1 << CGEventType.rightMouseDown.rawValue)

    guard let eventTap = CGEvent.tapCreate(
      tap: .cgSessionEventTap,
      place: .headInsertEventTap,
      options: .defaultTap,
      eventsOfInterest: eventMask,
      callback: eventCallback,
      userInfo: nil
    ) else {
      print("[ERR] Failed to create mouse handling event; possibly Accessibility related?")
      return
    }

    self.eventTap = eventTap
    runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)

    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource!, .commonModes)

    // Enable the event tap
    CGEvent.tapEnable(tap: eventTap, enable: true)
    
    // Set startime
    startTime = Int64(DispatchTime.now().uptimeNanoseconds / 1_000_000)
    
    print("[LOG] Listening for mouse clicks...")
    CFRunLoopRun()
  }

  // Stop monitoring mouse events
  func stop() {
    if let eventTap = eventTap {
      // Disable the event tap
      CGEvent.tapEnable(tap: eventTap, enable: false)
      self.eventTap = nil
      print("[LOG] Stopped listening for mouse clicks.")
    }
  }
}
