//
//  Extensions.swift
//  clove
//
//  Created by Tolu Oluwagbemi on 07/03/2023.
//

import UIKit

class ConstrainChain {
    var chain: String = ""
    var host: UIView!
    var viewIndex: Int = 0
    var subviews: [UIView] = []
    init(_ host: UIView) {
        self.host = host
    }
    
    func vertical(_ startMargin: CGFloat) -> ConstrainChain {
        chain += "V:|-(\(startMargin))-"
        return self
    }
    
    func vertical(_ startMargin: String) -> ConstrainChain {
        chain += "V:|-(\(startMargin))-"
        return self
    }
    func horizontal(_ startMargin: CGFloat) -> ConstrainChain {
        chain += "H:|-(\(startMargin))-"
        return self
    }
    
    func horizontal(_ startMargin: String) -> ConstrainChain {
        chain += "H:|-(\(startMargin))-"
        return self
    }
    
    func view(_ subView: UIView) -> ConstrainChain {
        if subviews.firstIndex(of: subView) == nil {
            host.addSubview(subView)
            subviews.append(subView)
        }
        chain += "[v\(viewIndex)]-"
        viewIndex += 1
        return self
    }
    func view(_ subView: UIView, _ size: CGFloat) -> ConstrainChain {
        if subviews.firstIndex(of: subView) == nil {
            host.addSubview(subView)
            subviews.append(subView)
        }
        chain += "[v\(viewIndex)(\(size))]-"
        viewIndex += 1
        return self
    }
    func view(_ subView: UIView, _ size: String) -> ConstrainChain {
        if subviews.firstIndex(of: subView) == nil {
            host.addSubview(subView)
            subviews.append(subView)
        }
        chain += "[v\(viewIndex)(\(size))]-"
        viewIndex += 1
        return self
    }
    func gap(_ margin: CGFloat) -> ConstrainChain {
        chain += "(\(margin))-"
        return self
    }
    func gap(_ margin: String) -> ConstrainChain {
        chain += "(\(margin))-"
        return self
    }
    
    func end(_ margin: CGFloat) {
        chain += "(\(margin))-|"
        host.addConstraints(format: chain, views: subviews)
    }
    func end(_ margin: String) {
        chain += "(\(margin))-|"
        host.addConstraints(format: chain, views: subviews)
    }
}

extension UIView {
    
    func addConstraints(format: String, views: UIView...) {
        addConstraints(format: format, views: views)
    }
    
    func addConstraints(format: String, views: [UIView]) {
        var viewDict = [String: Any]()
        for(index, view) in views.enumerated() {
            view.translatesAutoresizingMaskIntoConstraints = false
            let key = "v\(index)"
            viewDict[key] = view
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewDict))
    }
    
    func constrain(type: ConstraintType, _ views: UIView..., margin: Float = 0) {
        switch type {
        case .horizontalFill:
            for view in views {
                addConstraints(format: "H:|-\(margin)-[v0]-\(margin)-|", views: view)
            }
        case .verticalFill:
            for view in views {
                addConstraints(format: "V:|-\(margin)-[v0]-\(margin)-|", views: view)
            }
        case .verticalCenter:
            for view in views {
                addConstraints(format: "V:|-(>=\(margin))-[v0]-(>=\(margin))-|", views: view)
                view.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            }
        case .horizontalCenter:
            for view in views {
                addConstraints(format: "H:|-(>=\(margin))-[v0]-(>=\(margin))-|", views: view)
                view.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            }
        }
    }
    
    func add() -> ConstrainChain {
        return ConstrainChain(self)
    }
    
    func showIndicator(size: UIActivityIndicatorView.Style, color: UIColor, background: UIColor) {
        let loadIndicator = UIActivityIndicatorView()
        loadIndicator.style = size
        loadIndicator.color = color
        
        let wrapper = UIView()
        wrapper.tag = 0x77234
        wrapper.backgroundColor = background
        wrapper.addSubview(loadIndicator)
        wrapper.constrain(type: .verticalCenter, loadIndicator)
        wrapper.constrain(type: .horizontalCenter, loadIndicator)
        wrapper.isUserInteractionEnabled = true
        wrapper.addGestureRecognizer(UITapGestureRecognizer())
        wrapper.layer.cornerRadius = layer.cornerRadius
        
        addSubview(wrapper)
        add().vertical(0).view(wrapper).end(0)
        add().horizontal(0).view(wrapper).end(0)
        loadIndicator.startAnimating()
    }
    
    func showIndicator(size: UIActivityIndicatorView.Style, color: UIColor) {
        showIndicator(size: size, color: color, background: UIColor.create(0xFFFFFF, dark: 0x000000).withAlphaComponent(size == .large ? 0.6 : 0.9))
    }
    
    func hideIndicator() {
        for v: UIView in subviews {
            if v.tag == 0x77234 {
                v.removeFromSuperview()
            }
        }
    }
    
    func addSubviews(views: UIView...) {
        for view in views {
            addSubview(view)
        }
    }
    
    func scale(by scale: CGFloat) {
        self.contentScaleFactor = scale
        for subview in self.subviews {
            subview.scale(by: scale)
        }
    }
    
    func debugLines(color: UIColor?) {
        self.layer.borderWidth = 1
        self.layer.borderColor = color?.cgColor
    }
    func debugLines() {
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.red.cgColor
    }
    
    func getImage(scale: CGFloat? = nil) -> UIImage? {
        let bounds = self.bounds
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 3.0)
        if let context = UIGraphicsGetCurrentContext()  {
            self.layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
        return nil
    }
}

extension UILabel {
    convenience init(_ text: String, _ color: UIColor?, _ font: UIFont?) {
        self.init()
        self.text = text
        self.font = UIFont.systemFont(ofSize: 12)
        if color != nil {
            self.textColor = color!
        }
        if font != nil {
            self.font = font
        }
    }
}

extension Data {
    func json() -> Dictionary<String, Any> {
        do {
            return try JSONSerialization.jsonObject(with: self, options: []) as! Dictionary<String, Any>
        } catch {
            print(error.localizedDescription)
            return [:]
        }
    }
    func toJsonArray() -> [Any]? {
        do {
            return try JSONSerialization.jsonObject(with: self, options: .mutableContainers) as? [Any]
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
}

enum ConstraintType {
    case horizontalFill
    case verticalFill
    case horizontalCenter
    case verticalCenter
}

extension UIImage {
    
    func resize(_ size: CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0);
        
        self.draw(in: CGRect(x:0, y:0, width:size.width, height:size.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        return newImage
    }
    
    func rotate(_ deg: CGFloat ) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(deg)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: deg)
            draw(in: CGRect(x: -origin.y, y: -origin.x,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return rotatedImage ?? self
        }
        
        return self
        
    }
    
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

extension Encodable {
    var dictionary: [String: Any] {
        return (try? JSONSerialization.jsonObject(with: JSONEncoder().encode(self))) as? [String: Any] ?? [:]
    }
    var nsDictionary: NSDictionary {
        return dictionary as NSDictionary
    }
}

extension UIImageView {
    func asButton() {
        contentMode = .center
        layer.borderWidth = 1
        layer.borderColor = UIColor.separator.cgColor
        layer.cornerRadius = 15
    }
}

extension UIButton {
    convenience init(_ text: String, font: UIFont? = UIFont.systemFont(ofSize: 17), image: UIImage? = UIImage()) {
        self.init()
        self.setTitle(text, for: .normal)
        self.titleLabel?.font = font
        self.configuration = .filled()
        self.configuration?.contentInsets = .init(top: 14, leading: 40, bottom: 14, trailing: 40)
        self.configuration?.cornerStyle = .capsule
        self.configuration?.baseBackgroundColor = .accent
        self.configuration?.baseForegroundColor = .blackWhite
        if image != nil {
            self.setImage(image, for: .normal)
        }
    }
    
    func rightImage() {
        self.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        self.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        self.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
    }
    
    func disable(_ disable: Bool) {
        self.isEnabled = !disable
        if disable {
            self.alpha = 0.4
        }else {
            self.alpha = 1
        }
    }
    
}

extension Character {
    var isSimpleEmoji: Bool {
        guard let firstScalar = unicodeScalars.first else { return false }
        return firstScalar.properties.isEmoji && firstScalar.value > 0x238C
    }
    
    var isCombinedIntoEmoji: Bool { unicodeScalars.count > 1 && unicodeScalars.first?.properties.isEmoji ?? false && unicodeScalars.last?.properties.isEmoji ?? false }
    
    var isEmoji: Bool { isSimpleEmoji || isCombinedIntoEmoji }
}

extension String {
    var isSingleEmoji: Bool { count == 1 && containsEmoji }
    var containsEmoji: Bool { contains { $0.isEmoji } }
    var containsOnlyEmoji: Bool { !isEmpty && !contains { !$0.isEmoji } }
    var emojiString: String { emojis.map { String($0) }.reduce("", +) }
    var emojis: [Character] { filter { $0.isEmoji } }
    var emojiScalars: [UnicodeScalar] { filter { $0.isEmoji }.flatMap { $0.unicodeScalars } }
}

//extension UITextField {
//    convenience init(_ hint: String) {
//        self.init()
//        self.placeholder = hint;
//        self.backgroundColor = UIColor.formInput
//        self.textColor = UIColor.black_white
//        self.clipsToBounds = true
//        self.layer.cornerRadius = 22
//        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 20))
//        self.leftViewRect(forBounds: CGRect(x: 0, y: 0, width: 16, height: 20))
//        self.leftViewMode = .always
//    }
//}

extension UITableView {
    convenience init(background: UIColor, delegate: UITableViewDelegate, dataSource: UITableViewDataSource) {
        self.init()
        self.estimatedRowHeight = UITableView.automaticDimension
        self.tableFooterView = UIView(frame: CGRect.zero)
        self.separatorStyle = .none
        self.backgroundColor = background
        self.delegate = delegate
        self.dataSource = dataSource
    }
    
}

extension UINavigationController {
    
    public func presentTransparentNavigationBar() {
        navigationBar.setBackgroundImage(UIImage(), for:UIBarMetrics.default)
        navigationBar.shadowImage = UIImage()
    }
    
    public func hideTransparentNavigationBar() {
        //        setNavigationBarHidden(true, animated:false)
        navigationBar.setBackgroundImage(UINavigationBar.appearance().backgroundImage(for: UIBarMetrics.default), for:UIBarMetrics.default)
        navigationBar.shadowImage = UINavigationBar.appearance().shadowImage
    }
    
    func configureNavigationBar(withTitle title: String, largeTitleColor: UIColor, tintColor: UIColor, navBarColor: UIColor, smallTitleColorWhenScrolling: UIUserInterfaceStyle, prefersLargeTitles: Bool) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.largeTitleTextAttributes = [.foregroundColor: largeTitleColor]
        appearance.backgroundColor = navBarColor
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.prefersLargeTitles = prefersLargeTitles
        navigationController?.title = title
        navigationController?.navigationBar.tintColor = tintColor
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.overrideUserInterfaceStyle = smallTitleColorWhenScrolling
    }
}

extension NSMutableData {
    
    func appendString(_ value : String) {
        let data = value.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}

extension NSMutableAttributedString {
    @discardableResult func bold(_ text:String, size: CGFloat, weight: UIFont.Weight) -> NSMutableAttributedString {
        let attrs:[NSAttributedString.Key: Any] = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: size, weight: weight)]
        let boldString = NSMutableAttributedString(string:"\(text)", attributes:attrs)
        self.append(boldString)
        return self
    }
    
    @discardableResult func boldUnderline(_ text:String, size: CGFloat) -> NSMutableAttributedString {
        let attrs:[NSAttributedString.Key: Any] = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: size), NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
        let boldString = NSMutableAttributedString(string:"\(text)", attributes:attrs)
        self.append(boldString)
        return self
    }
    
    @discardableResult func normal(_ text:String)->NSMutableAttributedString {
        let normal =  NSAttributedString(string: text)
        self.append(normal)
        return self
    }
}


extension UIColor {
    convenience init(hex: Int) {
        self.init(red: CGFloat((hex >> 16) & 0xff) / 255.0, green: CGFloat((hex >> 8) & 0xff) / 255.0, blue: CGFloat(hex & 0xff) / 255.0, alpha: 1)
    }
    
    static let green = UIColor(hex: 0xC1EEA7)
    static let red = UIColor(hex: 0xFFBCBC)
    static let orange = UIColor(hex: 0xFFD9AD)
    
    static let accent = UIColor(hex: 0x784AC2)
    static let primary = UIColor(hex: 0x2E466B)
    static let titleText = create(0x262626, dark: 0xcdcdcd)
    static let inputText = create(0x707070, dark: 0xa0a0a0)
    
    static let background = create(0xFFFFFF, dark: 0x101010)
    static let darkBackground = create(0xf5f5f5, dark: 0x252525)
    static let text = create(0x494949, dark: 0xc0c0c0)
    static let darkText = create(0x000000, dark: 0xe0e0e0)
    static let lightText = create(0x9c9c9c, dark: 0x7f7f7f)
    static let black = UIColor(hex: 0x000000)
    static let white = UIColor(hex: 0xFFFFFF)
    static let blackWhite = UIColor.create(0x101010, dark: 0xf0f0f0)
    
    static let separator = UIColor.create(0xd8d8d8, dark: 0x424242)
    static let separatorLight = UIColor.create(0xF0F0F0, dark: 0x1F1F1F)
    
    static func create(_ light: Int, dark: Int) -> UIColor {
        return UIColor(dynamicProvider: { trait in
            return trait.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light)
        })
    }
}

func Localize(_ string: String) -> String {
    return NSLocalizedString(string, comment: "")
}

extension Date {
    var milliseconds: Int64 {
        Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return (calendar.locale?.calendar.dateComponents(Set(components), from: self))!
    }
    
    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return (calendar.locale?.calendar.component(component, from: self))!
    }
    
    func set(_ component: Calendar.Component, value: Int, calendar: Calendar = Calendar.current) -> Date {
        return (calendar.locale?.calendar.date(bySetting: component, value: value, of: self))!
    }
    
    static func from(string: String) -> Date? {
        return self.from(string: string, with: "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX")
    }
    
    static func from(string: String, with format: String) -> Date? {
        let df = DateFormatter()
        df.dateFormat = format
        return df.date(from: string)
    }
    
    func string(with format: String) -> String{
        let df = DateFormatter()
        df.dateFormat = format
        return df.string(from: self)
    }
    
    func toString() -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return df.string(from: self)
    }
    
    static func time(since fromDate: Date) -> String {
        guard fromDate < Date() else { return "1s" }
        
        let allComponents: Set<Calendar.Component> = [.second, .minute, .hour, .day, .weekOfYear, .month, .year]
        let components:DateComponents = Calendar.current.dateComponents(allComponents, from: fromDate, to: Date())
        
        for (period, timeAgo) in [
            ("y", components.year ?? 0),
            ("M", components.month ?? 0),
            ("w", components.weekOfYear ?? 0),
            ("d", components.day ?? 0),
            ("h", components.hour ?? 0),
            ("m", components.minute ?? 0),
            ("s", components.second ?? 0),
        ] {
            if timeAgo > 0 {
                return "\(timeAgo.of(period))"
            }
        }
        
        return "1s"
    }
}

extension Int {
    func of(_ name: String) -> String {
        return "\(self)\(name)"
    }
}

extension UITextView {
    
    override open var bounds: CGRect {
        didSet {
            self.resizePlaceholder()
        }
    }
    
    public var placeholder: String? {
        get {
            var placeholderText: String?
            
            if let placeholderLabel = self.viewWithTag(100) as? UILabel {
                placeholderText = placeholderLabel.text
            }
            
            return placeholderText
        }
        set {
            if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
                placeholderLabel.text = newValue
                placeholderLabel.sizeToFit()
            } else {
                self.addPlaceholder(newValue!)
            }
        }
    }
    
    @objc public func textViewDidChange(_ sender: NSNotification) {
        guard let textView = sender.object as? UITextView else { return }
        if let placeholderLabel = textView.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = !textView.text.isEmpty
        }
    }
    
    private func resizePlaceholder() {
        if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
            let labelX = self.textContainerInset.left + textContainer.lineFragmentPadding
            let labelY = self.textContainerInset.top
            let labelWidth = max(self.frame.width, 120)
            let labelHeight = placeholderLabel.frame.height
            placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
        }
    }
    
    private func addPlaceholder(_ placeholderText: String) {
        let placeholderLabel = UILabel()
        placeholderLabel.text = placeholderText
        placeholderLabel.sizeToFit()
        placeholderLabel.font = self.font
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.tag = 100
        placeholderLabel.isHidden = !self.text.isEmpty
        self.addSubview(placeholderLabel)
        self.resizePlaceholder()
        NotificationCenter.default.addObserver(self, selector: #selector(textViewDidChange),
                                               name: NSNotification.Name("UITextViewTextDidChangeNotification"),
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(textViewDidChange), name: NSNotification.Name("UITextViewTextDidChangeSelection"), object: nil)
    }
}
