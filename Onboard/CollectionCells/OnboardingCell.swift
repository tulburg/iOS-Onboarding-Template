//
//  OnboardingBaseCell.swift
//  Onboard
//
//  Created by Tolu Oluwagbemi on 14/03/2023.
//

import UIKit

class OnboardingCell: UICollectionViewCell, UITextFieldDelegate, VerificationCodeProtocol, CountryPickerDelegate {
    
    var textInput: UITextField!
    var datePicker: UIDatePicker!
    var question: String!
    var config: OBFormConfig!
    var delegate: OBDelegate!
    var phoneInput: UITextField!
    
    var questionLabel: UILabel!
    var inputContainer: UIView!
    var verificationCode: VerificationCode!
    var dateContainer: UIView!
    var dateLabel: UILabel!
    var selectedDate: Date?
    var phoneContainer: UIView!
    var countryCode: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        questionLabel = buildQuestion()
        inputContainer = buildTextInput()
        verificationCode = buildVerificationCode()
        dateContainer = buildDatePicker()
        phoneContainer = buildPhone()
        
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
        }else if config.type == .Phone {
            phoneInput.textContentType = .telephoneNumber
            phoneInput.keyboardType = .phonePad
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
            dateContainer.isHidden = false
            questionLabel.isHidden = false
            if config.datePickerConfig != nil {
                datePicker.date = selectedDate ?? config.datePickerConfig!.date
                datePicker.minimumDate = config.datePickerConfig?.minDate
                datePicker.maximumDate = config.datePickerConfig?.maxDate
            }
            
            contentView.add().vertical(24).view(questionLabel).gap(24)
                .view(dateContainer).end(">=24")
            contentView.constrain(type: .horizontalFill, questionLabel, dateContainer, margin: 24)
        }
        
        if config.type == .Phone {
            phoneContainer.isHidden = false
            contentView.add().vertical(24).view(questionLabel).gap(24)
                .view(phoneContainer).end(">=24")
            contentView.constrain(type: .horizontalFill, questionLabel, phoneContainer, margin: 24)
        }
        
    }
    
    override func prepareForReuse() {
        contentView.removeConstraints(contentView.constraints)
        [questionLabel, inputContainer, verificationCode, dateContainer, phoneContainer].forEach{ $0?.isHidden = true }
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
    
    func buildPhone() -> UIView {
        let container = UIView()
        let country = UIView()
        country.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(chooseCountry)))
        let chevron = UIImageView(image: UIImage(systemName: "chevron.down")?.withTintColor(.primary).resize(CGSize(width: 16, height: 8)))
        chevron.contentMode = .center
        countryCode = UILabel("🇺🇸 +1", .text, .systemFont(ofSize: 28, weight: .semibold))
        if let countryNumber = UserDefaults.standard.string(forKey: "ob_phone_country") {
            countryCode.text = countryNumber
        }
        let line = UIView()
        line.backgroundColor = .gray
        country.add().vertical(0).view(countryCode, 40).gap(0).view(line, 2).end(">=0")
        country.constrain(type: .horizontalFill, countryCode, line)
        
        let input = UIView()
        let inputLine = UIView()
        inputLine.backgroundColor = .gray
        phoneInput = UITextField()
        phoneInput.backgroundColor = UIColor.clear
        phoneInput.textColor = .accent
        phoneInput.delegate = self
        phoneInput.font = .systemFont(ofSize: 28, weight: .semibold)
        input.add().vertical(0).view(phoneInput, 40).gap(0).view(inputLine, 2).end(0)
        input.constrain(type: .horizontalFill, phoneInput, inputLine)
        
        container.add().horizontal(0).view(country, 120).gap(16).view(input).end(0)
        container.constrain(type: .verticalFill, country, input)
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
        if config.type == .Phone {
            self.delegate?.OBControllerToggleReadyState(ready: phoneInput.text!.count > 5)
        }
    }
    
    func hideKeyboard() {
        if textInput.isFirstResponder {
            textInput.resignFirstResponder()
        }
        if verificationCode.isFirstResponder {
            verificationCode.resignFirstResponder()
        }
        if phoneInput.isFirstResponder {
            phoneInput.resignFirstResponder()
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
            if config.type == .Phone {
                phoneInput.becomeFirstResponder()
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
            if config.type == .Phone {
                phoneInput.resignFirstResponder()
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
        selectedDate = sender.date
    }
    
    @objc func chooseCountry() {
        let countryPicker = CountryPickerViewController()
        countryPicker.selectedCountry = "US"
        countryPicker.delegate = self
        (delegate as? OnboardingController)?.present(countryPicker, animated: true)
        DispatchQueue.main.async {
            countryPicker.searchTextField.becomeFirstResponder()
        }
    }
    
    func countryPicker(didSelect country: Country) {
        countryCode.text = country.isoCode.getFlag() + " +" + country.phoneCode
        DispatchQueue.main.async {
            self.textInput.becomeFirstResponder()
        }
    }
}

enum OBFormType: String {
    case Name
    case Username
    case Email
    case VerificationCode
    case Date
    case Phone
    
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

