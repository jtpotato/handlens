//
//  FileName.swift
//
//
//  Created by Joel Tan on 30/8/2024.
//

import Foundation

func makeFileName(prefix: String = "screen_recording") -> String {
    // Get the current date and time
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
    let timestamp = dateFormatter.string(from: Date())

    // Create the filename with the timestamp
    let filename = "\(prefix)_\(timestamp).mov"

    return filename
}
