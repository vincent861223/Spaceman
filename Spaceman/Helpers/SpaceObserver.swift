//
//  SpaceObserver.swift
//  Spaceman
//
//  Created by Sasindu Jayasinghe on 23/11/20.
//

import Cocoa
import Foundation

class SpaceObserver {
    private var workspace: NSWorkspace?
    private let mainDisplay = "Main"
    private let conn = _CGSDefaultConnection()
    var statusBar: StatusBar?
    
    init() {
        configureObservers()
    }
    
    private func configureObservers() {
        workspace = NSWorkspace.shared
        
        workspace?.notificationCenter.addObserver(
            self,
            selector: #selector(updateSpaceInformation),
            name: NSWorkspace.activeSpaceDidChangeNotification,
            object: workspace
        )
//
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(updateSpaceInformation),
//            name: NSApplication.didUpdateNotification,
//            object: nil
//        )
    }
    
    @objc public func updateSpaceInformation() {
        let displays = CGSCopyManagedDisplaySpaces(conn) as! [NSDictionary]
//        let activeDisplay = CGSCopyActiveMenuBarDisplayIdentifier(conn) as? String
//        let allSpaces: NSMutableArray = []
        var activeSpaceID = -1
        var spacesIndex = 0
        var mySpaces: [Space] = []
        
        for d in displays {
            guard let currentSpaces = d["Current Space"] as? [String: Any],
                  let spaces = d["Spaces"] as? [[String: Any]],
                  let displayID = d["Display Identifier"] as? String
            else {
                continue
            }
            
            // The active space for the current display in the loop
            activeSpaceID = currentSpaces["ManagedSpaceID"] as! Int
            
            if activeSpaceID == -1 {
                DispatchQueue.main.async {
                    print("Can't find current space")
                }
                return
            }
            
            // Spaces for the current display in the loop
            for s in spaces {
                var space = Space(displayID: displayID, spaceNumber: spacesIndex + 1, isCurrentSpace: false, isFullScreen: false)
                space.isCurrentSpace = activeSpaceID == s["ManagedSpaceID"] as! Int
                space.isFullScreen = s["TileLayoutManager"] as? [String: Any] != nil
                
                mySpaces.append(space)
                spacesIndex += 1
            }
        }
        
        self.statusBar?.updateStatusBar()
    }
}
