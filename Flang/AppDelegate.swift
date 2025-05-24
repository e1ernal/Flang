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
    
    private var inputSource: InputSource
    
    private var showInputSourceName: Bool = false {
        didSet {
            UserDefaults.standard.set(showInputSourceName, forKey: "showInputSourceName")
        }
    }
    
    // MARK: - Initialization
    override init() {
        statusBar = NSStatusBar.system
        statusBarItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)
        inputSource = InputSource()
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    func applicationWillFinishLaunching(_ notification: Notification) {
        inputSource.delegate = self
        showInputSourceName = UserDefaults.standard.bool(forKey: "showInputSourceName")
    }
    func applicationDidFinishLaunching(_ notification: Notification) {
        configureStatusBarItemButton()
        configureStatusBarItemMenu()
    }
    
    // MARK: - Actions
    @objc
    private func showInputSourceNamePressed() {
        showInputSourceName.toggle()
    }
    
    @objc
    private func quitPressed() {
        NSApplication.shared.terminate(nil)
    }
    
    // MARK: - Public Methods
    func inputSourceDidChange() {
        statusBarItem.button?.title = inputSource.name
    }
    
    // MARK: - Private Methods
    private func configureStatusBarItemButton() {
        statusBarItem.button?.title = inputSource.name
    }
    
    private func configureStatusBarItemMenu(){
        let menu = NSMenu()
//        
//        let allSources = InputSourceHelper.getAllInputSources()
//        for source in allSources {
//            let item = NSMenuItem(
//                title: source.name,
//                action: nil,
//                keyEquivalent: ""
//            )
//            print(source)
//            print(sources.get(source.id))
//            item.target = self
//            let image = NSImage(named: "Flags/ru")
//            image?.size = CGSize(width: 32.3, height: 16.15)
//            item.image = image
//            item.state = .on
//            menu.addItem(item)
//        }
//        
//        // Show Input Source Name
//        let showInputSourceNameItem = NSMenuItem(
//            title: (showInputSourceName ? "Hide" : "Show") + " Input Source Name",
//            action: #selector(showInputSourceNamePressed),
//            keyEquivalent: ""
//        )
//        
        // Quit
        let quitItem = NSMenuItem(
            title: "Quit Flang",
            action: #selector(quitPressed),
            keyEquivalent: "q"
        )
//        
//        // Targets
//        showInputSourceNameItem.target = self
//        quitItem.target = self
//        
//        // Add Items
//        menu.addItem(.separator())
//        menu.addItem(showInputSourceNameItem)
//        menu.addItem(.separator())
        menu.addItem(quitItem)
//        
        statusBarItem.menu = menu
    }
    
    // MARK: - Deinitialization
    deinit { print("Deinit \(String(describing: AppDelegate.self))") }
}
