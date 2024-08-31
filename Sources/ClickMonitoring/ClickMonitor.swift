//
//  ClickMonitor.swift
//
//
//  Created by Joel Tan on 30/8/2024.
//

import CoreGraphics
import Foundation

class ClickMonitor {
    // MARK: - Properties
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    var clickEvents: [ClickEvent] = []
    private static var current: ClickMonitor?

    // MARK: - Initialization
    init() {
        ClickMonitor.current = self
    }

    // MARK: - Public Methods
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
        CGEvent.tapEnable(tap: eventTap, enable: true)

        print("[LOG] Listening for mouse clicks...")
        CFRunLoopRun()
    }

    func stop() {
        if let eventTap = eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
            self.eventTap = nil
            print("[LOG] Stopped listening for mouse clicks.")
        }
    }

    // MARK: - Private Methods
    private func callback(event: CGEvent) {
        let eventTime = machTimeToNanoseconds(mach_absolute_time())
        let globalLocation = event.location
        let screenPixelLocation = convertToScreenPixels(globalLocation)

        clickEvents.append(ClickEvent(location: screenPixelLocation, time: eventTime))
    }

    private func convertToScreenPixels(_ point: CGPoint) -> CGPoint {
        let mainDisplay = CGMainDisplayID()

        let displayBounds = CGDisplayBounds(mainDisplay)
        let displayMode = CGDisplayCopyDisplayMode(mainDisplay)

        // Calculate scale factor, default to 1.0 if unable to determine
        let scaleFactor = displayMode?.pixelWidth ?? 0 > 0 ?
            CGFloat(displayMode?.pixelWidth ?? 0) / CGFloat(displayMode?.width ?? 1) : 1.0

        // Convert global coordinates to screen pixel coordinates
        let screenX = (point.x - displayBounds.origin.x) * scaleFactor
        let screenY = (point.y - displayBounds.origin.y) * scaleFactor

        return CGPoint(x: screenX, y: screenY)
    }

    // MARK: - Event Callback
    private var eventCallback: CGEventTapCallBack = { _, type, event, _ in
        guard let monitor = ClickMonitor.current else { return Unmanaged.passUnretained(event) }

        if type == .leftMouseDown {
            monitor.callback(event: event)
        }
        return Unmanaged.passUnretained(event)
    }
}
