//
//  OnboardingBaseCell.swift
//  Onboard
//
//  Created by Tolu Oluwagbemi on 14/03/2023.
//

import UIKit

class OnboardingCell: UICollectionViewCell {
    
    var textInput: UITextField!
    var question: String!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func build(_ config: [String: String]) {
        
        let question = buildQuestion(config["title"]!)
        let input = buildTextInput(config["placeholder"]!)
        
        contentView.add().vertical(24).view(question).gap(40).view(input).end(">=24")
        contentView.constrain(type: .horizontalFill, question, input, margin: 24)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func buildQuestion(_ title: String) -> UILabel {
        return UILabel(title, .titleText, .systemFont(ofSize: 28, weight: .semibold))
    }
    
    func buildTextInput(_ placeholder: String) -> UIView {
        let container = UIView()
        let line = UIView()
        line.backgroundColor = .gray
        textInput = UITextField()
        textInput.backgroundColor = UIColor.clear
        textInput.textColor = .accent
        textInput.placeholder = placeholder
        textInput.font = .systemFont(ofSize: 22, weight: .semibold)
        container.add().vertical(0).view(textInput, 40).gap(0).view(line, 2).end(0)
        container.constrain(type: .horizontalFill, textInput, line)
        return container
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        hideKeyboard()
    }
    
    func hideKeyboard() {
        if textInput.isFirstResponder {
            textInput.resignFirstResponder()
        }
    }
}

enum SubmitType {
    case nestable
}
enum FormType: String {
    case SimpleText
    
    func Config(_ title: String, _ placeholder: String, submitType: SubmitType) -> [String: String] {
        return [
            "type": self.rawValue,
            "title": title,
            "placeholder": placeholder
        ]
    }
}
