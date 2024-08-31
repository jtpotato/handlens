//
//  GetChar.swift
//
//
//  Created by Joel Tan on 30/8/2024.
//

import Foundation

extension FileHandle {
    func enableRawMode() -> termios {
        var raw = termios()
        tcgetattr(fileDescriptor, &raw)

        let original = raw
        raw.c_lflag &= ~UInt(ECHO | ICANON)
        tcsetattr(fileDescriptor, TCSADRAIN, &raw)
        return original
    }

    func restoreRawMode(originalTerm: termios) {
        var term = originalTerm
        tcsetattr(fileDescriptor, TCSADRAIN, &term)
    }
}

/// Gets immediate keypress.
func getch() -> UInt8 {
    let handle = FileHandle.standardInput
    let term = handle.enableRawMode()
    defer { handle.restoreRawMode(originalTerm: term) }

    var byte: UInt8 = 0
    read(handle.fileDescriptor, &byte, 1)
    return byte
}
