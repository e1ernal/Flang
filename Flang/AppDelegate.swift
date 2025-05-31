//
//  AppDelegate.swift
//  Flang
//
//  Created by e1ernal on 21.05.2025.
//

import Cocoa
import Carbon

final class AppDelegate: NSObject, NSApplicationDelegate, InputSourceMonitoring {
    // MARK: - Public Properties
    
    // MARK: - Private Properties
    private var statusBar: NSStatusBar
    private var statusBarItem: NSStatusItem
    private var statusBarItemMenu: NSMenu
    
    private var inputSourceManager = InputSourceManager()
    
    // MARK: - Initialization
    override init() {
        statusBar = NSStatusBar.system
        statusBarItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)
        statusBarItemMenu = NSMenu()
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    func applicationWillFinishLaunching(_ notification: Notification) {
        inputSourceManager.delegate = self
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        configureStatusBarItemButton()
        configureStatusBarItemMenu()
    }
    
    // MARK: - Actions
    @objc
    private func quitPressed() {
        NSApplication.shared.terminate(nil)
    }
    
    @objc
    private func selectInputSourcePressed(tag: Int) {
//        func setInputSource(_ inputSourceID: String) {
//            let inputSources = TISCreateInputSourceList(nil, false).takeRetainedValue() as! [TISInputSource]
//            
//            for source in inputSources {
//                if let sourceID = TISGetInputSourceProperty(source, kTISPropertyInputSourceID) {
//                    let id = Unmanaged<CFString>.fromOpaque(sourceID).takeUnretainedValue() as String
//                    if id == inputSourceID {
//                        TISSelectInputSource(source)
//                        break
//                    }
//                }
//            }
//        }
    }
    
    // MARK: - Public Methods
    func inputSourceDidChange() {
        updateMenuItem()
    }
    
    // MARK: - Private Methods
    private func configureStatusBarItemButton() {
        statusBarItem.button?.title = inputSourceManager.inputSource.name
        statusBarItem.button?.image = inputSourceManager.inputSource.image
    }
    
    private func configureStatusBarItemMenu(){
        statusBarItemMenu = NSMenu()
        
        // Input Sources
        inputSourceManager.inputSources.forEach { source in
            let sourceItem = NSMenuItem(
                title: source.name,
                action: #selector(selectInputSourcePressed),
                keyEquivalent: ""
            )
            
            sourceItem.image = source.image
            sourceItem.tag = source.name.hashValue
            sourceItem.state = source.isSelected ? .on : .off
            statusBarItemMenu.addItem(sourceItem)
        }
        
        // Quit
        let quitItem = NSMenuItem(
            title: "Quit Flang",
            action: #selector(quitPressed),
            keyEquivalent: "q"
        )
        
        statusBarItemMenu.addItem(.separator())
        statusBarItemMenu.addItem(quitItem)
        
        statusBarItem.menu = statusBarItemMenu
    }
    
    private func updateMenuItem() {
        DispatchQueue.main.async {
            let inputSource = self.inputSourceManager.inputSource
            let inputSources = self.inputSourceManager.inputSources
            
            self.statusBarItem.button?.title = inputSource.name
            self.statusBarItem.button?.image = inputSource.image
            
            self.statusBarItemMenu.items.forEach { item in
                let inputSource = inputSources.first { inputSource in
                    item.tag == inputSource.name.hashValue
                }
                
                guard let inputSource else { return }
                
                item.title = inputSource.name
                item.state = inputSource.isSelected ? .on : .off
            }
            
        }
    }
    
    // MARK: - Deinitialization
    deinit { print("Deinit \(String(describing: AppDelegate.self))") }
}
