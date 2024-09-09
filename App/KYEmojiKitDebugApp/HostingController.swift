//
//  SwiftUIView.swift
//  
//
//  Created by Kyle on 2024/7/26.
//

import SwiftUI
import UIKit
@testable import KYEmojiKit

struct HostingController: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        ViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

final class ViewController: UIViewController {
    override func viewDidLoad() {
        view.backgroundColor = .yellow
        let textView = EmojiTextView()
        textView.showEmojiSuggestion = true
        textView.setInputView(height: 368) {
            EmojiPanel(manager: textView.emojiManager)
        }
        textView.backgroundColor = .red
        
        view.addSubview(textView)
        textView.frame = CGRect(x: 0, y: 300, width: view.frame.width, height: 100)
    }
}

#Preview {
    HostingController()
        .ignoresSafeArea()
}
