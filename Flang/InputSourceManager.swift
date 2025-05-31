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

struct InputSource {
    let name: String
    let isSelected: Bool
    let image: NSImage?
}

final class InputSourceManager {
    // MARK: - Public Properties
    var delegate: InputSourceMonitoring?
    
    /// Get current Input Source
    var inputSource: InputSource {
        get {
            let currentSource = TISCopyCurrentKeyboardInputSource().takeUnretainedValue()
            let image = NSImage(named: currentSource.name)
            image?.size = imageSize
            return InputSource(name: currentSource.name,
                               isSelected: true,
                               image: image
            )
        }
    }
    
    /// Get current Input Sources
    var inputSources: [InputSource] {
        get {
            let currentSource = TISCopyCurrentKeyboardInputSource().takeUnretainedValue()
            let inputSourceNSArray = TISCreateInputSourceList(nil, false).takeRetainedValue() as NSArray
            let elements = inputSourceNSArray as! [TISInputSource]
            
            let inputSources = elements.filter({
                $0.category == TISInputSource.Category.keyboardInputSource && $0.isSelectable
            })
            
            return inputSources.map {
                let image = NSImage(named: $0.name)
                image?.size = imageSize
                
                return InputSource(name: $0.name,
                                   isSelected: currentSource.id == $0.id ? true : false,
                                   image: image
                )
            }
        }
    }
    
    // MARK: - Private Properties
    private var notificationCenter: CFNotificationCenter
    
    private let imageSize: CGSize = CGSize(width: 24, height: 18)
    
    // MARK: - Initialization
    init() {
        notificationCenter = CFNotificationCenterGetDistributedCenter()
        inputSourceChangedNotification()
    }
    
    // MARK: - Public Methods
    
    // MARK: - Private Methods
    private func inputSourceChangedNotification() {
        let callback: CFNotificationCallback = { _, observer, name, object, userInfo in
            if name?.rawValue == kTISNotifySelectedKeyboardInputSourceChanged {
                let inputSourceManager = Unmanaged<InputSourceManager>.fromOpaque(UnsafeRawPointer(observer!)!).takeUnretainedValue()
                inputSourceManager.delegate?.inputSourceDidChange()
            }
        }
        
        CFNotificationCenterAddObserver(notificationCenter,
                                        UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque()),
                                        callback,
                                        kTISNotifySelectedKeyboardInputSourceChanged,
                                        nil,
                                        .deliverImmediately)
    }
    
    // MARK: - Deinitialization
    deinit {
        CFNotificationCenterRemoveEveryObserver(notificationCenter,
                                                UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque()))
    }
}

extension TISInputSource {
    enum Category {
        static var keyboardInputSource: String {
            return kTISCategoryKeyboardInputSource as String
        }
    }
    
    private func getProperty(_ key: CFString) -> AnyObject? {
        guard let cfType = TISGetInputSourceProperty(self, key) else {
            return nil
        }
        
        return Unmanaged<AnyObject>.fromOpaque(cfType).takeUnretainedValue()
    }
    
    var id: String { return getProperty(kTISPropertyInputSourceID) as! String }
    var name: String { return getProperty(kTISPropertyLocalizedName) as! String }
    var category: String { return getProperty(kTISPropertyInputSourceCategory) as! String }
    var isSelectable: Bool { return getProperty(kTISPropertyInputSourceIsSelectCapable) as! Bool }
}
