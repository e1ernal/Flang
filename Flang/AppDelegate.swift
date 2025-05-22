//
//  AppDelegate.swift
//  Flang
//
//  Created by e1ernal on 21.05.2025.
//

import Cocoa
import Carbon

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBar: NSStatusBar!
    private var statusBarItem: NSStatusItem!
    
    private var sources = Sources()
    private var timer: Timer?
    private var showInputSourceName: Bool {
        didSet {
            configureMenu()
            UserDefaults.standard.set(showInputSourceName, forKey: "showInputSourceName")
        }
    }
    
    override init() {
        showInputSourceName = UserDefaults.standard.bool(forKey: "showInputSourceName")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Application Lifecycle
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        configureStatusBarItem()
        configureInputSourceMonitoring()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        timer?.invalidate()
    }
    
    // MARK: - Configuration
    
    private func configureStatusBarItem() {
        statusBar = NSStatusBar.system
        statusBarItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)
        
        configureMenu()
    }
    
    private func configureMenu(){
        let menu = NSMenu()
        
        let allSources = InputSourceHelper.getAllInputSources()
        for source in allSources {
            let item = NSMenuItem(
                title: source.name,
                action: nil,
                keyEquivalent: ""
            )
            
            item.target = self
            let image = NSImage(named: "Flags/ru")
            image?.size = CGSize(width: 32.3, height: 16.15)
            item.image = image
            item.state = .on
            menu.addItem(item)
        }
        
        // Show Input Source Name
        let showInputSourceNameItem = NSMenuItem(
            title: (showInputSourceName ? "Hide" : "Show") + " Input Source Name",
            action: #selector(showInputSourceNamePressed),
            keyEquivalent: ""
        )
        
        // Quit
        let quitItem = NSMenuItem(
            title: "Quit Flang",
            action: #selector(quitPressed),
            keyEquivalent: "q"
        )
        
        // Targets
        showInputSourceNameItem.target = self
        quitItem.target = self
        
        // Add Items
        menu.addItem(.separator())
        menu.addItem(showInputSourceNameItem)
        menu.addItem(.separator())
        menu.addItem(quitItem)
        
        statusBarItem.menu = menu
    }
    
    private func configureInputSourceMonitoring() {
        timer = Timer.scheduledTimer(
            timeInterval: 0.5,
            target: self,
            selector: #selector(updateStatusBarItem),
            userInfo: nil,
            repeats: true
        )
    }
    
    // MARK: - Actions
    
    @objc
    private func updateStatusBarItem() {
        guard
            let currentInputSource = TISCopyCurrentKeyboardInputSource()?.takeRetainedValue(),
            let sourceID = TISGetInputSourceProperty(currentInputSource, kTISPropertyInputSourceID)
        else { return }
        
        let fullId = Unmanaged<CFString>.fromOpaque(sourceID).takeUnretainedValue() as String
        let id = String(fullId.split(separator: ".").last ?? "")
        let source = sources.get(id)
        let image = NSImage(named: "Flags/\(source.flagCode)")
        image?.size = CGSize(width: 32.3, height: 16.15)
        let title = showInputSourceName ? source.nameShort : ""
        
        DispatchQueue.main.async {
            self.statusBarItem.button?.title = title
            self.statusBarItem.button?.image = image
        }
    }
    
    // MARK: - Menu Actions
    
    @objc
    private func showInputSourceNamePressed() {
        showInputSourceName.toggle()
    }
    
    @objc
    private func quitPressed() {
        NSApplication.shared.terminate(nil)
    }
}

