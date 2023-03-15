//
//  OnboardingBaseCell.swift
//  Onboard
//
//  Created by Tolu Oluwagbemi on 14/03/2023.
//

import UIKit

class OnboardingCell: UICollectionViewCell, UITextFieldDelegate, VerificationCodeProtocol {
    
    var textInput: UITextField!
    var datePicker: UIDatePicker!
    var question: String!
    var config: OBFormConfig!
    var delegate: OBDelegate!
    
    var questionLabel: UILabel!
    var inputContainer: UIView!
    var verificationCode: VerificationCode!
    var dateContainer: UIView!
    var dateLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        questionLabel = buildQuestion()
        inputContainer = buildTextInput()
        verificationCode = buildVerificationCode()
        dateContainer = buildDatePicker()
        
        contentView.backgroundColor = .background
    }
    
    func build(_ config: OBFormConfig) {
        self.config = config
        questionLabel.text = config.title
        textInput.placeholder = config.placeholder
        
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
        }
        if (config.type == .Name || config.type == .Email || config.type == .Username) {
            questionLabel.isHidden = false
            inputContainer.isHidden = false
            
            contentView.add().vertical(24).view(questionLabel).gap(24)
                .view(inputContainer, ">=40").end(">=24")
            contentView.constrain(type: .horizontalFill, questionLabel, inputContainer, margin: 24)
        }
        if (config.type == .VerificationCode) {
            questionLabel.isHidden = false
            verificationCode.isHidden = false
            contentView.add().vertical(24).view(questionLabel).gap(24)
                .view(verificationCode, 64).end(">=24")
            contentView.constrain(type: .horizontalFill, questionLabel, margin: 24)
            contentView.add().horizontal(24).view(verificationCode).end(">=0")
        }
        
        if (config.type == .Date) {
//            let formatter = DateFormatter()
//            formatter.dateFormat = "DD-MM-YYYY"
//            datePicker.date = Date(timeIntervalSinceNow: -(22 * 365 * 86400))
//            datePicker.minimumDate = formatter.date(from: "01-01-1920")
//            datePicker.maximumDate = Date(timeIntervalSinceNow: -(18 * 365 * 86400))
            dateContainer.isHidden = false
            questionLabel.isHidden = false
            if config.datePickerConfig != nil {
                datePicker.date = config.datePickerConfig!.date
                datePicker.minimumDate = config.datePickerConfig?.minDate
                datePicker.maximumDate = config.datePickerConfig?.maxDate
            }
            
            contentView.add().vertical(24).view(questionLabel).gap(24)
                .view(dateContainer).end(">=24")
            contentView.constrain(type: .horizontalFill, questionLabel, dateContainer, margin: 24)
        }
        
    }
    
    override func prepareForReuse() {
        contentView.removeConstraints(contentView.constraints)
        [questionLabel, inputContainer, verificationCode, dateContainer].forEach{ $0?.isHidden = true }
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
    
    func buildDatePicker() -> UIView {
        let container = UIView()
        
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.alpha = 1
        datePicker.backgroundColor = .background
        datePicker.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)
        datePicker.layer.cornerRadius = 12
        datePicker.clipsToBounds = true
        datePicker.inputView?.tintColor = .accent
        dateLabel = UILabel("12 December 2019", .accent, .systemFont(ofSize: 28, weight: .semibold))
        
        container.add().vertical(0).view(dateLabel, 32).gap(0).view(datePicker, 320).end(">=0")
        container.constrain(type: .horizontalFill, dateLabel, datePicker)
        
        return container
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        hideKeyboard()
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        checkReadyState(config)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        checkReadyState(config)
        return true
    }
    
    func checkReadyState(_ config: OBFormConfig) {
        if config.type == .Name {
            self.delegate?.OBControllerToggleReadyState(ready: textInput.text!.count > 0)
        }
        if config.type == .Username {
            let regex = "^[a-z0-9_]{3,32}$"
            let pred = NSPredicate(format: "SELF MATCHES %@", regex)
            self.delegate?.OBControllerToggleReadyState(ready: pred.evaluate(with: textInput.text!))
        }
        if config.type == .Email {
            let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailPred = NSPredicate(format: "SELF MATCHES %@", regex)
            self.delegate?.OBControllerToggleReadyState(ready: emailPred.evaluate(with: textInput.text!))
        }
        if config.type == .Date {
            self.delegate?.OBControllerToggleReadyState(ready: true)
        }
        if config.type == .VerificationCode {
            self.delegate?.OBControllerToggleReadyState(ready: verificationCode.numel == verificationCode.text?.count)
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
    
    func becomeActive(_ config: OBFormConfig) {
        DispatchQueue.main.async { [self] in
            if config.type == .Name || config.type == .Username || config.type == .Email {
                textInput.becomeFirstResponder()
            }
            if config.type == .VerificationCode {
                self.verificationCode.becomeFirstResponder()
            }
        }
        checkReadyState(config)
    }
    
    func resignActive(_ config: OBFormConfig) {
        DispatchQueue.main.async { [self] in
            if config.type == .Name || config.type == .Username || config.type == .Email {
                textInput.resignFirstResponder()
            }
            if config.type == .VerificationCode {
                self.verificationCode.resignFirstResponder()
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
    
    @objc func datePickerChanged(_ sender: UIDatePicker, value: Any) {
        dateLabel.text = sender.date.string(with: "d MMMM YYYY")
    }
    
}

enum OBFormType: String {
    case Name
    case Username
    case Email
    case VerificationCode
    case Date
    
    func Config(_ title: String, _ placeholder: String) -> OBFormConfig {
        return .init(type: self, title: title, placeholder: placeholder)
    }
    
    func Config(_ title: String, _ placeholder: String, datePickerConfig: OBDatePickerConfig) -> OBFormConfig {
        return .init(type: self, title: title, placeholder: placeholder, datePickerConfig: datePickerConfig)
    }
}

struct OBDatePickerConfig {
    var minDate: Date?
    var maxDate: Date?
    var date: Date
}

struct OBFormConfig {
    var type: OBFormType
    var title: String
    var placeholder: String
    var datePickerConfig: OBDatePickerConfig?
}

protocol OBDelegate {
    func OBControllerToggleReadyState(ready: Bool)
}

