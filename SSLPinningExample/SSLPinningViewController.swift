//
//  ViewController.swift
//  SSLPinningExample
//
//  Created by Maxim Sorokin on 31.07.2020.
//  Copyright © 2020 Maxim Sorokin. All rights reserved.
//

import UIKit

final class SSLPinningViewController: UIViewController {

    private let sslPinningView = SSLPinningView()
    private let sslPinningService = SSLPinningService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(sslPinningView)
        
        sslPinningView.sslPinningViewController = self
        sslPinningService.sslPinningViewController = self

        configureLayout()
    }
    
    private func configureLayout() {
        let constraint = [
            sslPinningView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sslPinningView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sslPinningView.topAnchor.constraint(equalTo: view.topAnchor),
            sslPinningView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        sslPinningView.setup(constraint: constraint)
    }
    
    func performButtonAction(with buttons: Buttons) {
        switch buttons {
        case .first:
            sslPinningService.testWithoutPin()

        case .second:
            sslPinningService.testWithAlamofireDefaultValidPin()
            
        case .third:
            sslPinningService.testWithAlamofireDefaultInvalidPin()
            
        case .fourth:
            sslPinningService.testWithNSURLSessionValidPin()
            
        case .five:
            sslPinningService.testWithNSURLSessionInvalidPin()
        }
    }
    
    func showResult(with success: Bool, errorText: String?) {
        sslPinningView.showResult(success: success, errorText: errorText)
    }
}

