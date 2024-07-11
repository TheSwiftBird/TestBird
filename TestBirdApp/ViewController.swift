//
//  ViewController.swift
//  TestBirdApp
//
//  Created by Yakov Manshin on 7/10/24.
//

import UIKit

class ViewController: UIViewController {
    
    private lazy var userManager: any UserManagerProtocol = UserManager(
        networkingService: NetworkingService(),
        dateFormatter: HatchDateFormatter()
    )
    
    @IBOutlet private weak var userInfoLabel: UILabel!
    
    @IBAction private func didTapLoadUserInfoButton(_ sender: UIButton) {
        Task {
            let userInfo = await userManager.infoForUser(withID: 123)
            DispatchQueue.main.async {
                self.userInfoLabel.text = userInfo
            }
        }
    }
    
}
