//
//  AddViewController.swift
//  Notes2
//
//  Created by by3m on 29.06.2023.
//

import UIKit

protocol AddViewControllerDelegate {
    func didFinishAdd()
}

class AddViewController: UIViewController {
        private var titleField: UITextField = {
        let field = UITextField()
        field.placeholder = "Title"
        field.textColor = .label
        field.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        return field
    }()
    private var bodyTextView: UITextView = {
       let view = UITextView()
        view.text = "Type in here..."
        view.font = UIFont.systemFont(ofSize: 18)
        view.textColor = .placeholderText
        view.clipsToBounds = true
        return view
    }()
    var delegate: AddViewControllerDelegate?
    
    
    override func viewWillLayoutSubviews() {
        view.backgroundColor = .systemBackground
        view.addSubViews(views: titleField, bodyTextView)
        titleField.frame = CGRect(x: 20,
                                  y: 120,
                                  width: view.width - 40,
                                  height: 44)
        bodyTextView.frame = CGRect(x: 16,
                                    y: titleField.bottom + 20, width: view.width - 32,
                                    height: view.bottom - 250)
    }


    override func viewDidLoad() {
        super.viewDidLoad()
     
        
        title = "Add Note"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapSaveButton))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back",
                                                           style: .done,
                                                           target: self,
                                                           action: #selector(didTapBackButton))
        bodyTextView.delegate = self
        titleField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateTextView), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTextView), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        bodyTextView.resignFirstResponder()
        titleField.resignFirstResponder()
    }
    
 @objc   func updateTextView(param: Notification) {
        let userInfo = param.userInfo
        
        let getKeyBoardRect = (userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardFrame = self.view.convert(getKeyBoardRect, to: view.window)
        
        if param.name == UIResponder.keyboardWillHideNotification {
            bodyTextView.contentInset = UIEdgeInsets.zero
        }else {
            bodyTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
            bodyTextView.scrollIndicatorInsets = bodyTextView.contentInset
        }
        bodyTextView.scrollRangeToVisible(bodyTextView.selectedRange)
    }

    @objc func didTapBackButton() {
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func didTapSaveButton() {
        if titleField.text!.isEmpty || bodyTextView.text.isEmpty {
            let alertController = UIAlertController(
                title: "Fields Required",
                message: "Please enter a title and body for your note!",
                preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "OK",
                                             style: .cancel,
                                             handler: nil)
            alertController.addAction(cancelAction)
            present(alertController, animated: true)
        
            return
        }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate
            .persistentContainer
            .viewContext
        let note = Note(context: managedContext)
        
        note.title = titleField.text!
        note.body = bodyTextView.text
        note.created = Date.ReferenceType.now
        
        do {
            try managedContext.save()
            let alertController = UIAlertController(title: "Note Saved",
                                                    message: "Note has been saved successfuly!", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "ok",
                                           style: .cancel) { [weak self] _ in
            guard let self = self else {return}
                self.delegate?.didFinishAdd()
            self.dismiss(animated: true) {
                self.dismiss(animated: true, completion: nil)
            }
        }
        
            alertController.addAction(okayAction)
            present(alertController, animated: true)
        
        } catch let error as NSError {
            fatalError("error saving person to core data\(error.userInfo)")
        }
}
    
}

extension AddViewController: UITextFieldDelegate, UITextViewDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        titleField.resignFirstResponder()
        if textField == titleField && !titleField.text!.isEmpty {
            bodyTextView.becomeFirstResponder()
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        titleField.resignFirstResponder()
        bodyTextView.becomeFirstResponder()
        return true
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == bodyTextView && bodyTextView.text == "Type in here..." {
            textView.text = ""
            bodyTextView.textColor = .label
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == bodyTextView &&
            bodyTextView.text.isEmpty {
            textView.text = "Type in here..."

            bodyTextView.textColor = .placeholderText
        }
    }
    
}

