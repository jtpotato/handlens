import Darwin

func getMachTimebase() -> (numer: UInt64, denom: UInt64) {
    var timebase = mach_timebase_info_data_t()
    mach_timebase_info(&timebase)
    return (UInt64(timebase.numer), UInt64(timebase.denom))
}

func machTimeToNanoseconds(_ machTime: UInt64) -> UInt64 {
    let timebase = getMachTimebase()
    return machTime * timebase.numer / timebase.denom
}
