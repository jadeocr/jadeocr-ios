//
//  FailureViewController.swift
//  jadeocr
//
//  Created by Jeremy Tow on 4/12/21.
//

import UIKit

class FailureViewController: UIViewController {
    var failureView: Failure?
    var matched: String?
    var correct: String?
    var passthroughDelegate: FailureDelegate?
    var delegate: FailureVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        failureView = Failure(matched: matched!, corrrect: correct!, delegate: passthroughDelegate!)

        self.view.frame = self.view.bounds
        self.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        self.view.addSubview(failureView!)
        failureView!.translatesAutoresizingMaskIntoConstraints = false

        failureView!.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1.0).isActive = true
        failureView!.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 1.0).isActive = true
        failureView!.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        failureView!.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate?.goingBack()
    }

}
