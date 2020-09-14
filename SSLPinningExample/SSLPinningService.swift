//
//  SSLPinningService.swift
//  SSLPinningExample
//
//  Created by Maxim Sorokin on 31.07.2020.
//  Copyright © 2020 Maxim Sorokin. All rights reserved.
//

import Alamofire
import Foundation

class SSLPinningService: NSObject {

    private let validDomain = "https://ssl-pinning-test.com"
    private let invalidDomain = "https://yandex.ru"
    private let shortValidDomain = "ssl-pinning-test.com"
    private let shortInvalidDomain = "yandex.ru"
    private let certificateURL = Bundle.main.url(forResource: "ssl-pinning-test.com", withExtension: "cer")
    
    private var session: Session?
    
    weak var sslPinningViewController: SSLPinningViewController?
    
    // MARK: - Test Alamofire
    
    func testWithoutPin() {
        Alamofire.AF.request(validDomain).response { [weak self] in
            self?.handle(responseIsNotNil: $0.response != nil, error: $0.error)
        }
    }
    
    func testWithAlamofireDefaultValidPin() {
        testWithAlamofireDefaultPin(domain: validDomain, shortDomain:  shortValidDomain)
    }
    
    func testWithAlamofireDefaultInvalidPin() {
        testWithAlamofireDefaultPin(domain: invalidDomain, shortDomain: shortInvalidDomain)
    }
    
    // MARK: - Test NSURLSession
    
    func testWithNSURLSessionValidPin() {
        testWithNSURLSessionPin(domain: validDomain)
    }
    
    func testWithNSURLSessionInvalidPin() {
        testWithNSURLSessionPin(domain: invalidDomain)
    }
}

private extension SSLPinningService {
    
    // MARK: - Test Alamofire

    func testWithAlamofireDefaultPin(domain: String, shortDomain: String) {
        let trustManager = ServerTrustManager(evaluators: [
            shortDomain: PinnedCertificatesTrustEvaluator()
        ])
        
        session = Session(configuration: .default,
                          delegate: SessionDelegate(),
                          startRequestsImmediately: true,
                          serverTrustManager: trustManager)
        
        session?.request(domain).response { [weak self] in
            self?.handle(responseIsNotNil: $0.response != nil, error: $0.error)
        }
    }
    
    // MARK: - Test NSURLSession
    
    func testWithNSURLSessionPin(domain: String) {
        guard let url = URL(string: domain) else {
            return
        }

        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        
        let task = session.dataTask(with: url, completionHandler: { [weak self] (data, response, error) in
            self?.handle(responseIsNotNil: response != nil, error: error)
        })
        task.resume()
    }
    
    // MARK: - Helper
    
    func handle(responseIsNotNil: Bool, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            self?.sslPinningViewController?.showResult(with: responseIsNotNil,
                                             errorText: error.debugDescription)
            print(error.debugDescription)
        }
    }
}

extension SSLPinningService: URLSessionDelegate {
    
    /// Запрашивает учетные данные у делегата в ответ на запрос проверки подлинности на уровне сеанса от удаленного сервера.
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge, // Объект, содержащий запрос на аутентификацию.
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        guard let trust = challenge.protectionSpace.serverTrust,
            SecTrustGetCertificateCount(trust) > 0 else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        // Сравниваем сертификат сервера с нашим собственным сохраненным сертификатом
        if let serverCertificate = SecTrustGetCertificateAtIndex(trust, 0) {
            let serverCertificateData = SecCertificateCopyData(serverCertificate) as Data

            if pinnedCertificates().contains(serverCertificateData) {
                completionHandler(.useCredential, URLCredential(trust: trust))
                return
            }
        }
        
        completionHandler(.cancelAuthenticationChallenge, nil)
    }
}

private extension SSLPinningService {
    
    func pinnedCertificates() -> [Data] {
        var certificates: [Data] = []
        
        if let pinnedCertificateURL = certificateURL {
            do {
                let pinnedCertificateData = try Data(contentsOf: pinnedCertificateURL)
                certificates.append(pinnedCertificateData)
            } catch (_) { }
        }
        
        return certificates
    }
    
    func pinnedKeys() -> [SecKey] {
        var publicKeys: [SecKey] = []
        
        if let pinnedCertificateURL = certificateURL {
            do {
                let pinnedCertificateData = try Data(contentsOf: pinnedCertificateURL) as CFData
                if let pinnedCertificate = SecCertificateCreateWithData(nil, pinnedCertificateData),
                    let key = publicKey(for: pinnedCertificate) {
                    publicKeys.append(key)
                }
            } catch (_) { }
        }
        
        return publicKeys
    }
    
    func publicKey(for certificate: SecCertificate) -> SecKey? {
        var publicKey: SecKey?
        
        let policy = SecPolicyCreateBasicX509()
        var trust: SecTrust?
        let trustCreationStatus = SecTrustCreateWithCertificates(certificate, policy, &trust)
        
        if let trust = trust, trustCreationStatus == errSecSuccess {
            publicKey = SecTrustCopyPublicKey(trust)
        }
        
        return publicKey
    }
    
}
