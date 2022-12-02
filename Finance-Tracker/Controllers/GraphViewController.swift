//
//  GraphViewController.swift
//  Finance-Tracker
//
//  Created by Petar Iliev on 2.12.22.
//

import UIKit

class GraphViewController: UIViewController {
    
    // Outlets
    @IBOutlet weak var highView: UIView!
    @IBOutlet weak var lowView: UIView!
    @IBOutlet weak var volumeView: UIView!
    @IBOutlet weak var openView: UIView!
    @IBOutlet weak var closedView: UIView!
    @IBOutlet weak var marketCapView: UIView!
    @IBOutlet weak var graphView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Customize view
        highView.layer.cornerRadius = K.viewCornerRadius
        lowView.layer.cornerRadius = K.viewCornerRadius
        volumeView.layer.cornerRadius = K.viewCornerRadius
        openView.layer.cornerRadius = K.viewCornerRadius
        closedView.layer.cornerRadius = K.viewCornerRadius
        marketCapView.layer.cornerRadius = K.viewCornerRadius
        graphView.layer.cornerRadius = K.viewCornerRadius
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Customize bar
        tabBarController?.navigationItem.hidesBackButton = false
        tabBarController?.navigationItem.title = "AAPL (Apple)"
        tabBarController?.navigationItem.backButtonTitle = "Hey"
    }
}
 
