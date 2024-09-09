//
//  ModelFrame.swift
//
//
//  Created by Kyle on 2024/8/15.
//

import Foundation
import SwiftUI

struct ModelFrame: Hashable {
    let id: String
    let frame: CGRect
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(frame.origin.x)
        hasher.combine(frame.origin.y)
    }
    
    init(id: String, frame: CGRect) {
        self.id = id
        self.frame = frame
    }
}

struct ModelFrameKey: PreferenceKey {
    static var defaultValue: Set<ModelFrame> = []
    
    static func reduce(value: inout Set<ModelFrame>, nextValue: () -> Set<ModelFrame>) {
        value = value.union(nextValue())
    }
}

struct ModelEnvironmentKey: EnvironmentKey {
    static var defaultValue: Set<ModelFrame> = []
}

extension EnvironmentValues {
    var modelFrames: Set<ModelFrame> {
        get { self[ModelEnvironmentKey.self] }
        set { self[ModelEnvironmentKey.self] = newValue }
    }
}
