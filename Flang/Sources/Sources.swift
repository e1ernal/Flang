//
//  Sources.swift
//  Flang
//
//  Created by e1ernal on 21.05.2025.
//

import Foundation

final class Sources {
    private var sources = [String: Source]()
    
    init() {
        guard let url = Bundle.main.url(forResource: "sources", withExtension: "json") else {
            print("Not found: 'sources.json'")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            sources = try decoder.decode([String: Source].self, from: data)
        } catch {
            print("Error loading: \(error.localizedDescription)")
        }
    }
    
    public func get(_ id: String) -> Source {
        guard let source = self.sources[id] else {
            return Source(
                name: "-",
                nameShort: "-",
                nameNative: "-",
                nameNativeShort: "-",
                flagEmoji: "-",
                flagCode: "-"
            )
        }
        
        return source
    }
}
