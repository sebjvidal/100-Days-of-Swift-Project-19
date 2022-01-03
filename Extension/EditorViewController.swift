//
//  EditorViewController.swift
//  Extension
//
//  Created by Seb Vidal on 01/01/2022.
//

import UIKit

class EditorViewController: UIViewController {
    
    @IBOutlet var scriptEditor: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        setupNotificationCenter()
    }
    
    func setupNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
    }

    @objc func save() {
        let defaults = UserDefaults.standard
        var scripts = defaults.array(forKey: "scripts") as? [String] ?? []
        scripts.append(scriptEditor.text)
        defaults.set(scripts, forKey: "scripts")
        
        let title = "Saved"
        let message = "Sucessfully saved script."
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(alertController, animated: true)
    }
    
    func setupNotificationCenter() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!

        let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            scriptEditor.contentInset = UIEdgeInsets.zero
        } else {
            scriptEditor.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }

        scriptEditor.scrollIndicatorInsets = scriptEditor.contentInset

        let selectedRange = scriptEditor.selectedRange
        scriptEditor.scrollRangeToVisible(selectedRange)
    }
    
}
