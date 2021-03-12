//
//  AuthorizationViewController.swift
//  git-it
//
//  Created by Marwan Osama on 3/5/21.
//

import UIKit
import RxSwift
import RxCocoa
import AuthenticationServices
import SafariServices

class AuthorizationViewController: UIViewController {
    
    
    

    @IBOutlet weak var authorizeButton: UIButton!
    @IBOutlet weak var termsButton: UIButton!
    
    private var webAuthenticationSession: ASWebAuthenticationSession?
    
    private let bag = DisposeBag()
    private lazy var viewModel: AuthorizationViewModel = {
        return AuthorizationViewModel()
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
              
        removeAllPreviousVCInNavigationStack()
        configureUI()
        bindAuthorizeButton()
        bindTermsButton()
        didRecieveAccessCode()
        didRecieveToken()
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    
    private func bindAuthorizeButton() {
        authorizeButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.showEmailAlert()
                print(self?.navigationController?.viewControllers.count)
                print(self?.navigationController?.viewControllers)
                print(UserDefaults.standard.string(forKey: "token") ?? "no token")
                
            }, onDisposed: {
                print("Authorize Button Disposed")
            }).disposed(by: bag)
    }
    
    private func didRecieveAccessCode() {
        viewModel.accessCodeBehavior
            .filter({ !$0.isEmpty })
            .subscribe(onNext: { [weak self] code in
                self?.viewModel.fetchAccessToken(accessCode: code)
            }, onDisposed: {
                print("accessCode Disposed")
            }).disposed(by: bag)
    }
    
    private func didRecieveToken() {
        viewModel.tokenBehavior
            .filter({ !$0.isEmpty })
            .subscribe(onNext: { [weak self] token in
                self?.webAuthenticationSession?.cancel()
                let vc = UIStoryboard(name: "TabBar", bundle: nil).instantiateInitialViewController()
                self?.navigationController?.pushViewController(vc!, animated: true)
                self?.removePreviousVCInNavigationStack()
            }, onDisposed: {
                print("Token Disposed")
            }).disposed(by: bag)
    }
    
    private func bindTermsButton() {
        termsButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let url = URL(string: "https://docs.github.com/en/github/site-policy/github-terms-of-service") else { return }
                let vc = SFSafariViewController(url: url)
                self?.present(vc, animated: true, completion: nil)
            }, onDisposed: {
                print("Terms Button Disposed")
            }).disposed(by: bag)
    }
    
    
    
    private func configureUI() {
        authorizeButton.layer.cornerRadius = 15
    }
    
    
    private func showEmailAlert() {
        
        let alertController = UIAlertController(title: "Authorization", message: "Enter your Email to authorize the Application, please.", preferredStyle: .alert)
        
        alertController.addTextField { tf in
            tf.placeholder = "Enter your E-mail"
            tf.font = UIFont.systemFont(ofSize: 13)
            tf.autocorrectionType = .no
            tf.borderStyle = .roundedRect
            tf.layer.borderWidth = 0.4
            tf.layer.borderColor = UIColor.label.cgColor
            tf.autocapitalizationType = .none
            tf.keyboardType = .emailAddress
            tf.keyboardAppearance = .default
        }
                
        let authorizeAction = UIAlertAction(title: "Authorize", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.webAuthenticationSession = self.viewModel.getAccessCode(account: alertController.textFields!.first!.text!)
            self.webAuthenticationSession?.presentationContextProvider = self
            self.webAuthenticationSession?.start()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.textFields?.first?.rx.text.orEmpty
            .map({ text -> Bool in
                let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
                return trimmedText.isEmpty
            })
            .subscribe(onNext: { (isEmpty) in
                authorizeAction.isEnabled = !isEmpty
            }).disposed(by: bag)
        
        alertController.addAction(authorizeAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    
    
}

extension AuthorizationViewController: ASWebAuthenticationPresentationContextProviding {
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return view.window ?? ASPresentationAnchor()
    }

    
}
