//
//  ViewController.swift
//  macScrcpyBar
//
//  Created by wsg_MacBook on 2023/7/24.
//

import Cocoa

class ViewController: NSViewController {
    var task: Process = Process()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = .white
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func openDevices(_ sender: Any) {
        if task.isRunning {
            return
        }
        
        runWindow()
    }
    
    func runWindow() {
        task = Process()
        task.environment = ["PATH": Bundle.main.resourcePath!]
        task.currentDirectoryPath = Bundle.main.resourcePath!
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", "scrcpy", "-S", "--stay-awake", "-m", "1081", "--always-on-top"]
        task.launch()
    }
    
}

