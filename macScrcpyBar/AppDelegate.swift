//
//  AppDelegate.swift
//  macScrcpyBar
//
//  Created by wsg_MacBook on 2023/7/24.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {

    var statusItem: NSStatusItem?
    var menu: NSMenu?
    var task: Process = Process()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let menuButton = statusItem?.button {
//            if #available(macOS 11.0, *) {
//                menuButton.image = NSImage(systemSymbolName: "iphone.homebutton.badge.play", accessibilityDescription: nil)
//            } else {
//                // Fallback on earlier versions
//            }
            menuButton.image = NSImage(named: "aaaa")
            menuButton.action = #selector(menuButtonToggle)
            menuButton.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        menu = NSMenu(title: "Status Bar Menu")
        menu?.delegate = self
        menu?.addItem(
            withTitle: "Quit",
            action: #selector(closeApp),
            keyEquivalent: "")
        
        checkAndCreateFolder()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        if task.isRunning {
            task.terminate()
        }
    }
    
    @objc func menuButtonToggle(sender: NSStatusBarButton) {
        if let eventType = NSApp.currentEvent?.type {
            if eventType == NSEvent.EventType.rightMouseUp  {
                if let menu = menu {
                    statusItem?.menu = menu
                    statusItem?.button?.performClick(nil)
                }
            } else {
                if task.isRunning {
                    return
                }
                
                runWindow()
            }
        }
    }
    
    @objc func menuDidClose(_ menu: NSMenu) {
       statusItem?.menu = nil
    }
    
    @objc func closeApp() {
        NSApplication.shared.terminate(self)
    }
    
    func runWindow() {
        task = Process()
        task.environment = ["PATH": Bundle.main.resourcePath!]
        
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", "scrcpy", "-S", "--stay-awake", "-m", "1081", "--always-on-top"]
        task.launch()
    }
    
    func checkAndCreateFolder() {
        let fileManager = FileManager.default
        let applicationsPath = "/Applications"
        let androidFolderName = "Android"
        let scrcpyFolderName = "scrcpy"
           
        let androidFolderPath = "\(applicationsPath)/\(androidFolderName)"
        let scrcpyFolderPath = "\(androidFolderPath)/\(scrcpyFolderName)"
           
        // Check if /Applications/Android folder exists, if not, create it
        if !fileManager.fileExists(atPath: androidFolderPath) {
            do {
                try fileManager.createDirectory(atPath: androidFolderPath, withIntermediateDirectories: false, attributes: nil)
                print("Android folder created at: \(androidFolderPath)")
            } catch {
                print("Error creating Android folder: \(error.localizedDescription)")
                return
            }
        } else {
            print("Android folder already exists at: \(androidFolderPath)")
        }
        
        // Enter /Applications/Android folder
        let androidProcess = Process()
        androidProcess.currentDirectoryPath = androidFolderPath
           
        // Check if /Applications/Android/scrcpy folder exists, if not, create it
        if !fileManager.fileExists(atPath: scrcpyFolderPath) {
            do {
                try fileManager.createDirectory(atPath: scrcpyFolderPath, withIntermediateDirectories: false, attributes: nil)
                print("scrcpy folder created at: \(scrcpyFolderPath)")
            } catch {
                print("Error creating scrcpy folder: \(error.localizedDescription)")
                   return
               }
        } else {
            print("scrcpy folder already exists at: \(scrcpyFolderPath)")
        }
           
        // Enter /Applications/Android/scrcpy folder
        let scrcpyProcess = Process()
        scrcpyProcess.currentDirectoryPath = scrcpyFolderPath

        // 设置要执行的 shell 命令
        let linkCommand = "ln -s \(Bundle.main.resourcePath!) /Applications/Android/scrcpy"
        scrcpyProcess.launchPath = "/bin/sh"
        scrcpyProcess.arguments = ["-c", linkCommand]

        let pipe = Pipe()
        scrcpyProcess.standardOutput = pipe

        scrcpyProcess.launch()
        scrcpyProcess.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: data, encoding: .utf8) {
            print("ln-s: \(linkCommand) \n output:\(output) ")
        }
        
        // Copy files from Bundle.main.resourcePath to the current folder
        let copyProcess = Process()
        copyProcess.currentDirectoryPath = scrcpyFolderPath
        let copyCommand = "cp -R \"\(Bundle.main.resourcePath!)/.\" ."
        copyProcess.launchPath = "/bin/sh"
        copyProcess.arguments = ["-c", copyCommand]

        let copyPipe = Pipe()
        copyProcess.standardOutput = copyPipe

        copyProcess.launch()
        copyProcess.waitUntilExit()

        let copyData = copyPipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: copyData, encoding: .utf8) {
            print("copy: \(output)")
        }
    }

}


