//
//  EmojiTextView.swift
//
//
//  Created by Kyle on 2024/8/1.
//

import UIKit
import SwiftUI
import os.log
import KYFoundation
import KYUIKit
import KYSwiftUI

public protocol EmojiTextViewDelegate: EmojiPanelDelegate {
    func transaction(from: EmojiKeyboardType, to: EmojiKeyboardType)
}

open class EmojiTextView: TextInputView {
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        // NOTE: Some internal API of UITextView will call _delegate instead of self.delegate/getter
        super.delegate = self
        textDragInteraction?.isEnabled = false
    }
    
    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    #if DEBUG
    private let logger = Logger(
        subsystem: (Bundle.main.bundleIdentifier.map { $0 + "." } ?? "") + "KYEmojiKit",
        category: "EmojiTextView"
    )
    #endif
    
    private var _emojiKeyboardType: EmojiKeyboardType = .normal
    
    open var emojiKeyboardType: EmojiKeyboardType {
        get { _emojiKeyboardType }
        set {
            guard newValue != _emojiKeyboardType else { return }
            _emojiKeyboardType = newValue
            switch newValue {
                case .normal:
                    showEmojiSuggestion = false
                    showEmojiKeyboard = false
                    _ = resignFirstResponder()
                case .keyboard:
                    showEmojiSuggestion = true
                    showEmojiKeyboard = false
                    _ = becomeFirstResponder()
                case .emoji:
                    showEmojiSuggestion = false
                    showEmojiKeyboard = true
                    _ = resignFirstResponder()
            }
        }
    }
    
    lazy var emojiManager = {
        let emojiManager = EmojiManager()
        emojiManager.delegate = self
        return emojiManager
    }()
    
    private lazy var emojiPanelVC = {
        let vc = UIViewController()
        vc.view.addGestureRecognizer(emojiPanelGesture)
        return vc
    }()
    
    public let accessoryViewHeight: CGFloat = 48.0
    
    public var showEmojiSuggestion = false {
        didSet {
            if showEmojiSuggestion {
                setInputAccessoryView(height: accessoryViewHeight, backgroundColor: .bg2) {
                    EmojiSuggestionBar(manager: emojiManager)
                }
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.inputAccessoryViewController?.view.alpha = 0
                } completion: { _ in
                    self.inputAccessoryViewController = nil
                }
            }
        }
    }
    
    public var showEmojiKeyboard: Bool {
        get { emojiPanelVC.view.alpha != 0 }
        set { setEmojiPanelHidden(!newValue) }
    }
    
    public var panelHeight: Double = 384 {
        didSet {
            emojiPanelVC.view.snp.updateConstraints { make in
                make.height.equalTo(panelHeight)
            }
        }
    }
    
    public func configEmojiPanel(height: Double? = nil, in container: UIView, parent: UIViewController) {
        if let height {
            panelHeight = height
        }
        parent.addChild(emojiPanelVC)
        container.addSubview(emojiPanelVC.view)
        emojiPanelVC.view.translatesAutoresizingMaskIntoConstraints = false
        emojiPanelVC.didMove(toParent: parent)
        setEmojiPanelHidden(true)
    }
    
    public func removeEmojiPanel() {
        emojiPanelVC.view.removeFromSuperview()
        emojiPanelVC.removeFromParent()
        emojiPanelVC.didMove(toParent: nil)
    }
    
    private lazy var emojiPanelGesture: UIGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handlePanelLongPressGesture(_:)))
        gesture.minimumPressDuration = 0.5
        gesture.delegate = self
        return gesture
    }()
    
    private func setEmojiPanelHidden(_ isHidden: Bool) {
        if isHidden {
            if let container = emojiPanelVC.view.superview {
                emojiPanelVC.view.snp.remakeConstraints { make in
                    make.leading.trailing.equalToSuperview()
                    make.top.equalTo(container.snp.bottom)
                    make.height.equalTo(panelHeight)
                }
            }
            let oldSubviews = emojiPanelVC.view.subviews
            let oldChildVC = emojiPanelVC.children
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                oldSubviews.forEach { $0.removeFromSuperview() }
                oldChildVC.forEach {
                    $0.removeFromParent()
                    $0.didMove(toParent: nil)
                }
            }
        } else {
            if let container = emojiPanelVC.view.superview {
                emojiPanelVC.view.snp.remakeConstraints { make in
                    make.leading.trailing.equalToSuperview()
                    make.bottom.equalToSuperview()
                    make.height.equalTo(panelHeight)
                }
            }
            let hosting = HostingController(rootView: EmojiPanel(manager: emojiManager))
            emojiPanelVC.addChild(hosting)
            hosting.loadViewIfNeeded()
            hosting.view.translatesAutoresizingMaskIntoConstraints = false
            emojiPanelVC.view.addSubview(hosting.view)
            hosting.view.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            hosting.didMove(toParent: emojiPanelVC)
        }
        emojiPanelVC.view.alpha = isHidden ? 0.0 : 1.0
    }
    
    public var plainText: String { attributedText.ky.plainText }
    
    override open weak var delegate: (any UITextViewDelegate)? {
        get { self }
        set {
            guard let newValue else {
                self.emojiDelegate = nil
                return
            }
            guard let emojiDelegate = newValue as? EmojiTextViewDelegate else {
                Log.runtimeIssues("Use non EmojiTextViewDelegate instance is not supported")
                self.emojiDelegate = nil
                return
            }
            self.emojiDelegate = emojiDelegate
        }
    }
    
    private weak var emojiDelegate: (any EmojiTextViewDelegate)?
    
    public var defaultAttributes: [NSAttributedString.Key: Any] = [:] {
        didSet {
            typingAttributes = defaultAttributes
        }
    }
    
    public var emojiFont: UIFont {
        get { font ?? .systemFont(ofSize: 14) }
        set { font = newValue }
    }
}

extension EmojiTextView: EmojiPanelDelegate {
    public func didClickSendButton() {
        #if DEBUG
        logger.debug(#function)
        #endif
        emojiDelegate?.didClickSendButton()
    }
    
    public func didClickDeleteButton() {
        #if DEBUG
        logger.debug(#function)
        #endif
        deleteBackward()
        emojiDelegate?.didClickDeleteButton()
    }
    
    public func didSelectEmoji(_ emoji: Emoji) {
        #if DEBUG
        logger.debug(#function)
        #endif
        let selectedRange = self.selectedRange
        let emojiAttributedString = NSMutableAttributedString(attributedString: emoji.attributedString(for: emojiFont))
        emojiAttributedString.addAttributes(defaultAttributes, range: emojiAttributedString.ky.rangeOfAll)
        let mutableAttributedText = NSMutableAttributedString(attributedString: self.attributedText)
        mutableAttributedText.replaceCharacters(in: selectedRange, with: emojiAttributedString)
        guard updateAttributedText(
            mutableAttributedText,
            with: NSMakeRange(selectedRange.location + emojiAttributedString.length, 0)
        ) else { return }
        scrollRangeToVisible(self.selectedRange)
        emojiManager.disableDeleteButton = plainText.isEmpty
        emojiDelegate?.didSelectEmoji(emoji)
    }
    
    open func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        #if DEBUG
        logger.debug(#function)
        #endif
        typingAttributes = defaultAttributes
        return emojiDelegate?.textViewShouldBeginEditing?(textView) ?? true
    }
    
    open func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        #if DEBUG
        logger.debug(#function)
        #endif
        return emojiDelegate?.textViewShouldEndEditing?(textView) ?? true
    }
    
    open func textViewDidBeginEditing(_ textView: UITextView) {
        #if DEBUG
        logger.debug(#function)
        #endif
        emojiDelegate?.textViewDidBeginEditing?(textView)
    }
    
    open func textViewDidEndEditing(_ textView: UITextView) {
        #if DEBUG
        logger.debug(#function)
        #endif
        emojiDelegate?.textViewDidEndEditing?(textView)
    }
    
    open func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        #if DEBUG
        logger.debug(#function)
        #endif
        guard text != "\n" else {
            didClickSendButton()
            return false
        }
        return emojiDelegate?.textView?(textView, shouldChangeTextIn: range, replacementText: text) ?? true
    }
    
    open func textViewDidChange(_ textView: UITextView) {
        #if DEBUG
        logger.debug(#function)
        #endif
        guard refreshTextUI() else { return }
        emojiManager.disableDeleteButton = plainText.isEmpty
        emojiDelegate?.textViewDidChange?(textView)
    }
    
    private func refreshTextUI() -> Bool {
        guard !text.isEmpty else { return true }
        if let markedTextRange = markedTextRange,
           let _ = position(from: markedTextRange.start, offset: 0) {
            return true // 正处于输入拼音还未点确定的中间状态
        }
        let selectedRange = selectedRange
        let attributedComment = NSMutableAttributedString(string: plainText, attributes: defaultAttributes)
        // 匹配表情
        EmojiDataManager.shared.replaceEmoji(for: attributedComment, font: emojiFont)
        attributedComment.addAttributes(defaultAttributes, range: attributedComment.ky.rangeOfAll)
        
        let offset = attributedText.length - attributedComment.length
        return updateAttributedText(
            attributedComment,
            with: NSMakeRange(selectedRange.location - offset, 0)
        )
    }
    
    open func textViewDidChangeSelection(_ textView: UITextView) {
        #if DEBUG
        logger.debug(#function)
        #endif
        emojiDelegate?.textViewDidChangeSelection?(textView)
    }
    
    open func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        #if DEBUG
        logger.debug(#function)
        #endif
        
        selectedRange = NSRange(location: characterRange.location, length: 0)
        textViewDidChangeSelection(textView)
        emojiDelegate?.transaction(from: emojiKeyboardType, to: .keyboard)
        
        return emojiDelegate?.textView?(textView, shouldInteractWith: textAttachment, in: characterRange, interaction: interaction) ?? false
    }
}

// MARK: - EmojiTextView UITextView Override

extension EmojiTextView {
    private func updateAttributedText(_ mutable: NSMutableAttributedString, with range: NSRange) -> Bool {
        textStorage.setAttributedString(mutable)
        selectedRange = range
        return true
    }
    
    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        var size = super.sizeThatFits(size)
        guard attributedText.string.isEmpty else { return size }
        // Fix Apple's bug of sizeThatFits implementation
        if let paragraphStyle = typingAttributes[.paragraphStyle] as? NSParagraphStyle {
            size.height -= paragraphStyle.lineSpacing
        }
        return size
    }
    
    open override func becomeFirstResponder() -> Bool {
        #if DEBUG
        logger.debug(#function)
        #endif
        let newLineMenuItem = UIMenuItem(title: "new_line".ky.localized, action: #selector(insertNewLine))
        UIMenuController.shared.menuItems = [newLineMenuItem]
        return super.becomeFirstResponder()
    }
    
    open override func resignFirstResponder() -> Bool {
        #if DEBUG
        logger.debug(#function)
        #endif
        UIMenuController.shared.menuItems = nil
        return super.resignFirstResponder()
    }
    
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(insertNewLine) {
            return true
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    @objc 
    private func insertNewLine() {
        if let selectedRange = self.selectedTextRange {
            self.replace(selectedRange, withText: "\n")
        }
    }
    
    open override func cut(_ sender: Any?) {
        let text = attributedText.ky.plainTextForRange(range: selectedRange)
        guard let text, !text.isEmpty else { return }
        UIPasteboard.general.string = text
        
        let selectedRange = self.selectedRange
        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedText)
        mutableAttributedString.replaceCharacters(in: selectedRange, with: "")
        guard updateAttributedText(mutableAttributedString, with: NSMakeRange(selectedRange.location, 0)) else { return }
        delegate?.textViewDidChange?(self)
    }
    
    open override func copy(_ sender: Any?) {
        let text = attributedText.ky.plainTextForRange(range: selectedRange)
        guard let text, !text.isEmpty else { return }
        UIPasteboard.general.string = text
    }
    
    open override func paste(_ sender: Any?) {
        let text = UIPasteboard.general.string
        guard let text, !text.isEmpty else { return }
        let attributedPasteString = NSMutableAttributedString(string: text)
        EmojiDataManager.shared.replaceEmoji(for: attributedPasteString, font: emojiFont)
        let selectedRange = self.selectedRange
        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedText)
        mutableAttributedString.replaceCharacters(in: selectedRange, with: attributedPasteString)
        guard updateAttributedText(
            mutableAttributedString,
            with: NSMakeRange(selectedRange.location + attributedPasteString.length, 0)
        ) else { return }
        delegate?.textViewDidChange?(self)
    }
}

// MARK: - EmojiTextView + Gesture

extension EmojiTextView: UIGestureRecognizerDelegate {
    @objc
    private func handlePanelLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
            case .began, .changed:
                emojiManager.pressLocation = gesture.location(in: emojiPanelVC.view)
            default:
                emojiManager.resetPressLocation()
        }
    }
}
