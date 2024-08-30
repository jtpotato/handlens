//
//  File.swift
//  
//
//  Created by Joel Tan on 30/8/2024.
//

import Foundation

func makeFileName() -> String {
    // Get the current date and time
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
    let timestamp = dateFormatter.string(from: Date())
    
    // Create the filename with the timestamp
    let filename = "screen_recording_\(timestamp).mov"
    
    return filename
}
