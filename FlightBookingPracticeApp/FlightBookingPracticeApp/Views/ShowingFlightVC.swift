//
//  ShowingFlightVC.swift
//  FlightBookingPracticeApp
//
//  Created by Salamuddin on 10/11/23.
//

import UIKit

class ShowingFlightVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.isNavigationBarHidden = true
        
    }
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
    
        self.navigationController?.popViewController(animated: true)
    }



}
