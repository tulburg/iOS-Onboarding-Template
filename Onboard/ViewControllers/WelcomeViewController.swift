//
//  WelcomeViewController.swift
//  Onboard
//
//  Created by Tolu Oluwagbemi on 14/03/2023.
//

import UIKit

class OnboardingController: ViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var collectionView: UICollectionView!
    var indicator: UIView!
    var indicatorLastPosition: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        
        buildCollectionView()
        indicator = buildIndicator(8)
        
        view.add().vertical(safeAreaInset!.top + 24).view(indicator, 24).end(">=0")
        view.add().horizontal(24).view(indicator).end(">=0")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            self.indicate(1)
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: {
            self.indicate(2)
        })
    }
    
    func buildCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.isPagingEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = self
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
        func resize(_ child: UIView, _ size: CGFloat) {
            for c in indicator.constraints where c.firstAttribute == .height && (c.firstItem as? UIView) == child {
                c.constant = size
            }
            for c in indicator.constraints where c.firstAttribute == .width && (c.firstItem as? UIView) == child {
                c.constant = size
            }
            UIView.animate(withDuration: 0.5, animations: {
                child.layer.cornerRadius = size / 2
                child.backgroundColor = size == 10 ? .darkBackground : .accent
                self.indicator.layoutIfNeeded()
            })
        }
        if indicatorLastPosition != nil {
            resize(indicator.subviews[indicatorLastPosition!], 10)
        }
        resize(indicator.subviews[position], 16)
        indicatorLastPosition = position
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = UICollectionViewCell()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
}
