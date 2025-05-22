//
//  s.swift
//  Flang
//
//  Created by e1ernal on 22.05.2025.
//

import Cocoa
import Carbon

class InputSourceHelper {
    
    // Получаем все источники ввода с читаемыми названиями
    static func getAllInputSources() -> [(id: String, name: String, lang: String)] {
        let property = [kTISPropertyInputSourceType: kTISTypeKeyboardLayout] as CFDictionary
        guard let sources = TISCreateInputSourceList(property, false)?.takeRetainedValue() as? [TISInputSource] else {
            return []
        }
        
        return sources.compactMap { source in
            guard let id = getProperty(source, key: kTISPropertyInputSourceID) as? String,
                  let name = getLocalizedInputSourceName(source),
                  let langCode = getPrimaryLanguageCode(source),
                  let langName = getLanguageName(for: langCode) else {
                return nil
            }
            return (id: id, name: name, lang: langName)
        }
    }
    
    // Получаем красивое локализованное название источника ввода
    private static func getLocalizedInputSourceName(_ source: TISInputSource) -> String? {
        // Сначала пробуем получить локализованное имя
        if let localizedName = getProperty(source, key: kTISPropertyLocalizedName) as? String {
            return localizedName
        }
        
        // Если нет, пробуем получить имя через другие свойства
        if let name = getProperty(source, key: kTISPropertyInputSourceID) as? String {
            return name.components(separatedBy: ".").last?.replacingOccurrences(of: "-", with: " ").capitalized
        }
        
        return nil
    }
    
    // Получаем основной код языка для источника ввода
    private static func getPrimaryLanguageCode(_ source: TISInputSource) -> String? {
        guard let langs = getProperty(source, key: kTISPropertyInputSourceLanguages) as? [String],
              let primaryLang = langs.first else {
            return nil
        }
        return primaryLang
    }
    
    // Преобразуем код языка в читаемое название (например "ru" -> "Russian")
    private static func getLanguageName(for languageCode: String) -> String? {
        let locale = Locale(identifier: "en_US_POSIX") // Используем базовую локаль для консистентности
        
        if let languageName = locale.localizedString(forLanguageCode: languageCode) {
            return languageName
        }
        
        // Fallback для некоторых специальных случаев
        switch languageCode {
        case "zh-Hans": return "Chinese (Simplified)"
        case "zh-Hant": return "Chinese (Traditional)"
        case "yue": return "Cantonese"
        default: return languageCode
        }
    }
    
    // Вспомогательная функция для получения свойств
    private static func getProperty(_ source: TISInputSource, key: CFString) -> Any? {
        guard let value = TISGetInputSourceProperty(source, key) else {
            return nil
        }
        return Unmanaged<AnyObject>.fromOpaque(value).takeUnretainedValue()
    }
}
