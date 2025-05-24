//
//  Untitled.swift
//  Flang
//
//  Created by e1ernal on 24.05.2025.
//

import AppKit
import Carbon

protocol InputSourceMonitoring {
    func inputSourceDidChange()
}

final class InputSource {
    // MARK: - Public Properties
    var delegate: InputSourceMonitoring?
    
    var name: String {
        return currentSource.name
    }
    
    // MARK: - Private Properties
    private var notificationCenter: CFNotificationCenter
    
    private var currentSource: TISInputSource {
        return TISCopyCurrentKeyboardInputSource().takeUnretainedValue()
    }
    
    // MARK: - Initialization
    init() {
        notificationCenter = CFNotificationCenterGetDistributedCenter()
        observeInputSourceChangedNotification()
    }
    
    // MARK: - Public Methods
    
    // MARK: - Private Methods
    private func observeInputSourceChangedNotification() {
        let callback: CFNotificationCallback = { _, observer, name, object, userInfo in
            if name?.rawValue == kTISNotifySelectedKeyboardInputSourceChanged {
                let test = Unmanaged<InputSource>.fromOpaque(UnsafeRawPointer(observer!)!).takeUnretainedValue()
                test.delegate?.inputSourceDidChange()
            }
        }
        
        CFNotificationCenterAddObserver(notificationCenter,
                                        UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque()),
                                        callback,
                                        kTISNotifySelectedKeyboardInputSourceChanged,
                                        nil,
                                        .deliverImmediately)
    }
    
    private func switchInputSource() {
        var inputSources: [TISInputSource] = []
        
        let currentSource = TISCopyCurrentKeyboardInputSource().takeUnretainedValue()
        let inputSourceNSArray = TISCreateInputSourceList(nil, false).takeRetainedValue() as NSArray
        let elements = inputSourceNSArray as! [TISInputSource]
        
        inputSources = elements.filter({
            $0.category == TISInputSource.Category.keyboardInputSource && $0.isSelectable
        })
        
        for item in inputSources {
            if item.id != currentSource.id {
                TISSelectInputSource(item)
                break
            }
        }
    }
    
    // MARK: - Deinitialization
    deinit {
        CFNotificationCenterRemoveEveryObserver(notificationCenter, UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque()))
    }
}

extension TISInputSource {
    enum Category {
        static var keyboardInputSource: String {
            return kTISCategoryKeyboardInputSource as String
        }
    }
    
    private func getProperty(_ key: CFString) -> AnyObject? {
        let cfType = TISGetInputSourceProperty(self, key)
        if cfType != nil {
            return Unmanaged<AnyObject>.fromOpaque(cfType!).takeUnretainedValue()
        } else {
            return nil
        }
    }
    
    var id: String {
        return getProperty(kTISPropertyInputSourceID) as! String
    }
    
    var name: String {
        return getProperty(kTISPropertyLocalizedName) as! String
    }
    
    var category: String {
        return getProperty(kTISPropertyInputSourceCategory) as! String
    }
    
    var isSelectable: Bool {
        return getProperty(kTISPropertyInputSourceIsSelectCapable) as! Bool
    }
    
    var sourceLanguages: [String] {
        return getProperty(kTISPropertyInputSourceLanguages) as! [String]
    }
    
    var iconImageURL: URL? {
        return getProperty(kTISPropertyIconImageURL) as! URL?
    }
    
    var iconRef: IconRef? {
        return OpaquePointer(TISGetInputSourceProperty(self, kTISPropertyIconRef)) as IconRef?
    }
}
