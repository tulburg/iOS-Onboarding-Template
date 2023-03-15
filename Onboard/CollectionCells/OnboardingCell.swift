//
//  OnboardingBaseCell.swift
//  Onboard
//
//  Created by Tolu Oluwagbemi on 14/03/2023.
//

import UIKit

class OnboardingCell: UICollectionViewCell, UITextFieldDelegate, VerificationCodeProtocol {
    
    var textInput: UITextField!
    var question: String!
    var config: OBFormConfig!
    var delegate: OBDelegate!
    
    var questionLabel: UILabel!
    var inputContainer: UIView!
    var verificationCode: VerificationCode!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        questionLabel = buildQuestion()
        inputContainer = buildTextInput()
        verificationCode = buildVerificationCode()
        
        contentView.backgroundColor = .background
    }
    
    func build(_ config: OBFormConfig) {
        self.config = config
        questionLabel.text = config.title
        if config.type == .Name {
            textInput.keyboardType = .default
            textInput.textContentType = .familyName
        }else if config.type == .Username {
            textInput.textContentType = .username
            textInput.autocapitalizationType = .none
        }else if config.type == .Email {
            textInput.autocapitalizationType = .none
            textInput.textContentType = .emailAddress
            textInput.keyboardType = .emailAddress
        }else if config.type == .VerificationCode {
            
        }
        let inputView = (config.type == .Name || config.type == .Email || config.type == .Username) ? inputContainer : (config.type == .VerificationCode) ? verificationCode : UIView()
        textInput.placeholder = config.placeholder
        contentView.add().vertical(24).view(questionLabel).gap(24)
            .view(inputView!, config.type == .VerificationCode ? 64 : 40).end(">=24")
        if config.type == .VerificationCode {
            contentView.constrain(type: .horizontalFill, questionLabel, margin: 24)
            contentView.add().horizontal(24).view(verificationCode).end(">=0")
        }else {
            contentView.constrain(type: .horizontalFill, questionLabel, inputView!, margin: 24)
        }
    }
    
    override func prepareForReuse() {
        contentView.removeConstraints(contentView.constraints)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func buildQuestion() -> UILabel {
        return UILabel("", .titleText, .systemFont(ofSize: 18, weight: .semibold))
    }
    
    func buildTextInput() -> UIView {
        let container = UIView()
        let line = UIView()
        line.backgroundColor = .gray
        textInput = UITextField()
        textInput.backgroundColor = UIColor.clear
        textInput.textColor = .accent
        textInput.delegate = self
        textInput.font = .systemFont(ofSize: 28, weight: .semibold)
        container.add().vertical(0).view(textInput, 40).gap(0).view(line, 2).end(0)
        container.constrain(type: .horizontalFill, textInput, line)
        return container
    }
    
    func buildVerificationCode() -> VerificationCode {
        let verificationCode = VerificationCode(6, itemWidth: (contentView.frame.width / 6) - 16 )
        verificationCode.textColor = .blackWhite
        verificationCode.delegate = self
        
        return verificationCode
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        hideKeyboard()
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        checkReadyState()
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        checkReadyState()
        return true
    }
    
    func checkReadyState() {
        if (self.delegate != nil) {
            if config.type == .Name {
                self.delegate.OBControllerToggleReadyState(ready: textInput.text!.count > 0)
            }
            if config.type == .Username {
                let regex = "^[a-z0-9_]{3,32}$"
                let pred = NSPredicate(format: "SELF MATCHES %@", regex)
                self.delegate.OBControllerToggleReadyState(ready: pred.evaluate(with: textInput.text!))
            }
            if config.type == .Email {
                let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
                let emailPred = NSPredicate(format: "SELF MATCHES %@", regex)
                self.delegate.OBControllerToggleReadyState(ready: emailPred.evaluate(with: textInput.text!))
            }
        }
    }
    
    func hideKeyboard() {
        if textInput.isFirstResponder {
            textInput.resignFirstResponder()
        }
        if verificationCode.isFirstResponder {
            verificationCode.resignFirstResponder()
        }
    }
    
    func shouldSubmit() -> Bool {
        return true
    }
    
    func becomeActive() {
        DispatchQueue.main.async { [self] in
            if config.type == .Name || config.type == .Username || config.type == .Email {
                textInput.becomeFirstResponder()
            }else if config.type == .VerificationCode {
                self.verificationCode.becomeFirstResponder()
            }
        }
    }
    
    func textFieldValueChanged(_ textField: VerificationCode) {
        guard let count = textField.text?.count, count != 0 else {
            textField.resignFirstResponder()
            return
        }
        if count == textField.numel {
            delegate?.OBControllerToggleReadyState(ready: true)
        }else {
            delegate?.OBControllerToggleReadyState(ready: false)
        }
    }
    
}

enum OBSubmitType {
    case nestable
}
enum OBFormType: String {
    case Name
    case Username
    case Email
    case VerificationCode
    
    func Config(_ title: String, _ placeholder: String, submitType: OBSubmitType) -> OBFormConfig {
        return .init(type: self, title: title, placeholder: placeholder)
    }
}

struct OBFormConfig {
    var type: OBFormType
    var title: String
    var placeholder: String
}

protocol OBDelegate {
    func OBControllerToggleReadyState(ready: Bool)
}

