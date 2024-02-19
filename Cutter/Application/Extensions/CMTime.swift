//
//  CMTime.swift
//  Cutter
//
//  Created by Гаджиев Казим on 29.01.2024.
//

import AVFoundation

extension CMTime: Strideable {
    public func distance(to other: CMTime) -> TimeInterval {
        return TimeInterval((Double(other.value) / Double(other.timescale)) - (Double(self.value) /  Double(self.timescale)))
    }
    
    public func advanced(by n: TimeInterval) -> CMTime {
        var retval = self
        retval.value += CMTimeValue(n * TimeInterval(self.timescale))
        return retval
    }
}

extension CMTime {
    func formatted(_ format: String = "m:s") -> String {
        guard !seconds.isInfinite && !seconds.isNaN else { return "" }
        let components = format.components(separatedBy: ":")
        let intFormat = "%02d"
        var args: [Int] = []
        components.forEach { char in
            switch char {
            case "h":
                args.append(seconds.hour)
            case "m":
                args.append(seconds.minute)
            case "s":
                args.append(seconds.second)
            case "ms":
                args.append(seconds.millisecond)
            default:
                args.append(seconds.second)
            }
        }
        return String(
            format: components.map { _ in intFormat }.joined(separator: ":"),
            arguments: args
        )
    }
}

extension TimeInterval {
    var hour: Int {
        Int((self / 3600).truncatingRemainder(dividingBy: 3600))
    }
    var minute: Int {
        Int((self / 60).truncatingRemainder(dividingBy: 60))
    }
    var second: Int {
        Int(truncatingRemainder(dividingBy: 60))
    }
    var millisecond: Int {
        Int((self * 100).truncatingRemainder(dividingBy: 100))
    }

    func formatted(_ format: String = "m:s") -> String {
        guard !isInfinite && !isNaN else { return "" }
        let components = format.components(separatedBy: ":")
        let intFormat = "%02d"
        var args: [Int] = []
        components.forEach { char in
            switch char {
            case "h":
                args.append(hour)
            case "m":
                args.append(minute)
            case "s":
                args.append(second)
            case "ms":
                args.append(millisecond)
            default:
                args.append(second)
            }
        }
        return String(
            format: components.map { _ in intFormat }.joined(separator: ":"),
            arguments: args
        )
    }
}
