//
//  DiskStatus.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 19.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import UIKit
import AVFoundation

extension AVURLAsset {
    var fileSize: Int? {
        let keys: Set<URLResourceKey> = [.totalFileSizeKey, .fileSizeKey]
        let resourceValues = try? url.resourceValues(forKeys: keys)

        return resourceValues?.fileSize ?? resourceValues?.totalFileSize
    }
}

class DiskStatus {
    
    //MARK: Formatter MB only
    class func MBFormatter(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = ByteCountFormatter.Units.useMB
        formatter.countStyle = ByteCountFormatter.CountStyle.decimal
        formatter.includesUnit = false
        return formatter.string(fromByteCount: bytes) as String
    }
    
    //MARK: Get String Value
    class var totalDiskSpace:String {
        return ByteCountFormatter.string(fromByteCount: totalDiskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.binary)
    }
    
    class var freeDiskSpace:String {
        return ByteCountFormatter.string(fromByteCount: freeDiskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.binary)
    }
    
    class var usedDiskSpace:String {
        return ByteCountFormatter.string(fromByteCount: usedDiskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.binary)
    }
    
    
    //MARK: Get raw value
    class var totalDiskSpaceInBytes:Int64 {
        get {
            do {
                let systemAttributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String)
                let space = (systemAttributes[FileAttributeKey.systemSize] as? NSNumber)?.int64Value
                return space!
            } catch {
                return 0
            }
        }
    }
    
    class var freeDiskSpaceInBytes:Int64 {
        get {
            do {
                let systemAttributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String)
                let freeSpace = (systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber)?.int64Value
                return freeSpace!
            } catch {
                return 0
            }
        }
    }
    
    class var usedDiskSpaceInBytes:Int64 {
      let usedSpace = totalDiskSpaceInBytes - freeDiskSpaceInBytes
      return usedSpace
    }
    
}
