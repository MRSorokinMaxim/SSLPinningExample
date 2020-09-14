//
//  SSLPinningView.swift
//  SSLPinningExample
//
//  Created by Maxim Sorokin on 31.07.2020.
//  Copyright © 2020 Maxim Sorokin. All rights reserved.
//

import UIKit

enum Buttons: Int {
    case first, second, third, fourth, five
}

final class SSLPinningView: UIView {
    private let stackView = UIStackView()
    private let buttonFirst = UIButton()
    private let buttonSecond = UIButton()
    private let buttonThird = UIButton()
    private let buttonFourth = UIButton()
    private let buttonFive = UIButton()
    private let resultLabel = UILabel()
    private let scrollView = UIScrollView()
    
    private var allButtons: [UIButton] {
        [buttonFirst, buttonSecond, buttonThird, buttonFourth, buttonFive]
    }
    
    weak var sslPinningViewController: SSLPinningViewController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initializeView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initializeView() {
        addViews()
        bindViews()
        configureAppearance()
        configureLayout()
        localizableStrings()
    }
    
    private func addViews() {
        addSubview(scrollView)
        scrollView.addSubview(stackView)
        scrollView.addSubview(resultLabel)
        
        (allButtons).forEach { stackView.addArrangedSubview($0) }
    }
    
    private func bindViews() {
        allButtons.forEach { $0.addTarget(self, action: #selector(buttonAction(sender:)), for: .touchUpInside) }
    }
    
    private func configureAppearance() {
        stackView.contentMode = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 30
        stackView.axis = .vertical
        
        allButtons.forEach {
            $0.setTitleColor(.black, for: .normal)
            $0.titleLabel?.numberOfLines = 0
        }
        
        let buttonTags: [Buttons] = [.first, .second, .third, .fourth, .five]
        zip(allButtons, buttonTags).forEach { $0.0.tag = $0.1.rawValue }
        
        resultLabel.textColor = .black
        resultLabel.textAlignment = .center
        resultLabel.numberOfLines = 0
        
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
    }
    
    private func configureLayout() {
        var constraint = [
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        scrollView.setup(constraint: constraint)
        
        constraint = [
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.8),
            stackView.centerXAnchor.constraint(equalToSystemSpacingAfter: scrollView.centerXAnchor, multiplier: 1.0),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 100)
        ]
        stackView.setup(constraint: constraint)
        
        constraint = [
            resultLabel.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.8),
            resultLabel.centerXAnchor.constraint(equalToSystemSpacingAfter: scrollView.centerXAnchor, multiplier: 1.0),
            resultLabel.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 50),
            resultLabel.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -50)
        ]
        resultLabel.setup(constraint: constraint)
    }
    
    private func localizableStrings() {
        buttonFirst.setTitle("Тест без пиннинга, используя Alamofire", for: .normal)
        buttonSecond.setTitle("Тест с пиннингом и валидным доменом, используя Alamofire", for: .normal)
        buttonThird.setTitle("Тест с пиннингом и невалидным доменом, используя Alamofire", for: .normal)
        buttonFourth.setTitle("Тест с пиннингом, используя NSURLSession", for: .normal)
        buttonFive.setTitle("Тест с пиннингом и невалидным доменом, используя NSURLSession", for: .normal)
    }
    
    @objc private func buttonAction(sender: UIButton) {
        guard let button = Buttons(rawValue: sender.tag) else {
            return
        }
        
        showLoading()
        
        sslPinningViewController?.performButtonAction(with: button)
    }
    
    func showResult(success: Bool, errorText: String?) {
        resultLabel.text = success ? "✅ Success" : errorText != nil ? errorText : "🚫 Request failed"
    }
    
    private func showLoading() {
        resultLabel.text = "🚀 Полетели"
    }
}


extension UIView {
    func setup(constraint: [NSLayoutConstraint?]) {
        translatesAutoresizingMaskIntoConstraints = false
        constraint.forEach { $0?.isActive = true }
    }
}
