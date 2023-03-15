//
//  WelcomeViewController.swift
//  Onboard
//
//  Created by Tolu Oluwagbemi on 14/03/2023.
//

import UIKit

class OnboardingController: ViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var collectionView: UICollectionView!
    var indicator: UIView!
    var indicatorLastPosition: Int?
    let items: [[String: String]] = [
        FormType.SimpleText.Config("What's your full name?", "Fullname", submitType: .nestable),
        FormType.SimpleText.Config("Choose your username", "Username", submitType: .nestable)
    ]
    var cell: OnboardingCell!
    var navPanel: UIView!
    var nextButton: UIButton!
    var prevButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        
        buildCollectionView()
        indicator = buildIndicator(8)
        navPanel = buildNavPanel()
        
        view.add().vertical(safeAreaInset!.top + 24).view(indicator, 24).view(collectionView, view.frame.height - safeAreaInset!.top - 56).end(">=0")
        view.add().vertical(">=0").view(navPanel, 64).end(24 + safeAreaInset!.bottom)
        view.add().horizontal(24).view(indicator).end(">=0")
        view.constrain(type: .horizontalFill, collectionView)
        view.constrain(type: .horizontalFill, navPanel, margin: 24)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification , object: .none)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: .none)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardDidHideNotification, object: .none)
    }
    
    func buildCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.isPagingEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(OnboardingCell.self, forCellWithReuseIdentifier: "base_cell")
    }
    
    func buildIndicator(_ items: Int) -> UIView {
        let container = UIView()
        var constraint = container.add().horizontal(0)
        for i in 0...items {
            let counter = UIView()
            counter.backgroundColor = .darkBackground
            if i == items {
                constraint = constraint.view(counter, 10)
            }else {
                constraint = constraint.view(counter, 10).gap(14)
            }
            counter.layer.cornerRadius = 5
            container.add().vertical(">=0").view(counter, 10).end(">=0")
            counter.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        }
        constraint.end(0)
        return container
    }
    
    func indicate(_ position: Int) {
        guard position > -1 else { return }
        guard position < items.count else { return }
        func resize(_ child: UIView, _ size: CGFloat) {
            for c in indicator.constraints where c.firstAttribute == .height && (c.firstItem as? UIView) == child {
                c.constant = size
            }
            for c in indicator.constraints where c.firstAttribute == .width && (c.firstItem as? UIView) == child {
                c.constant = size
            }
            UIView.animate(withDuration: 0.5, animations: {
                child.layer.cornerRadius = size / 2
                child.backgroundColor = size == 10 ? .lightGray : .accent
                self.indicator.layoutIfNeeded()
            })
        }
        if indicatorLastPosition != nil {
            resize(indicator.subviews[indicatorLastPosition!], 10)
        }
        resize(indicator.subviews[position], 16)
        indicatorLastPosition = position
    }
    
    func buildNavPanel() -> UIView {
        let container = UIView()
        
        nextButton = UIButton(configuration: .filled())
        nextButton.configuration?.image = UIImage(systemName: "control")
        nextButton.transform = CGAffineTransform(rotationAngle: 1.57)
        nextButton.configuration?.cornerStyle = .capsule
        nextButton.configuration?.baseBackgroundColor = .accent
        nextButton.configuration?.baseForegroundColor = .white
        nextButton.addTarget(self, action: #selector(nextPage), for: .touchUpInside)
        
        prevButton = UIButton(configuration: .filled())
        prevButton.configuration?.image = UIImage(systemName: "control")
        prevButton.transform = CGAffineTransform(rotationAngle: -1.57)
        prevButton.configuration?.cornerStyle = .capsule
        prevButton.configuration?.baseBackgroundColor = .clear
        prevButton.configuration?.baseForegroundColor = .accent
        prevButton.addTarget(self, action: #selector(prevPage), for: .touchUpInside)
        
        container.add().horizontal(">=0").view(prevButton, 64).gap(24).view(nextButton, 64).end(0)
        container.add().vertical(">=0").view(nextButton, 64).end(0)
        container.add().vertical(">=0").view(prevButton, 64).end(0)
        return container
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let kFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            updateForKeyboard(kFrame)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        updateForKeyboard(.zero)
    }
    
    @objc func nextPage() {
        cell.hideKeyboard()
        let current = floor(self.collectionView.contentOffset.y / self.collectionView.frame.size.height)
        indicate(Int(current) + 1)
        self.collectionView.scrollToItem(at: IndexPath(row: Int(current) + 1, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    @objc func prevPage() {
        cell.hideKeyboard()
        let current = floor(self.collectionView.contentOffset.y / self.collectionView.frame.size.height)
        indicate(Int(current) - 1)
        self.collectionView.scrollToItem(at: IndexPath(row: Int(current) - 1, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    func updateForKeyboard(_ frame: CGRect) {
        for c in view.constraints where c.firstAttribute == .bottom && (c.secondItem as? UIView) == navPanel {
            c.constant = frame == .zero ? (24 + safeAreaInset!.bottom) : (frame.height + 24)
        }
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    // MARK: - Delegate functions
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        cell = (collectionView.dequeueReusableCell(withReuseIdentifier: "base_cell", for: indexPath) as? OnboardingCell)!
        cell.build(items[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        indicate(indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height - safeAreaInset!.bottom)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
