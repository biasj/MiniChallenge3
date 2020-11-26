//
//  TutorialViewController.swift
//  Memu
//
//  Created by Beatriz Sato on 03/11/20.
//

import UIKit

class TutorialViewController: UIViewController {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var navBar: UINavigationBar!
    
    let tutorialHasLaunched: Bool = UserDefaults.standard.bool(forKey: "tutorialHasLaunched")

    
    override func viewDidLoad() {
        super.viewDidLoad()
        if tutorialHasLaunched == false {
//            button.setTitle("Continuar", for: .normal)
//            button.setImage(UIImage(named: "jogar"), for: .normal)
            button.isHidden = false
            titleLabel.isHidden = false
            btnClose.isHidden = true
            navBar.isHidden = true
        }
        //button.setAttributedTitle(NSAttributedString(string: "Continuar"), for: .normal)
    }

    @IBAction func playTutorial(_ sender: Any) {
        print("hora de jogar")
        
        if tutorialHasLaunched == false {
            let storyboard = UIStoryboard(name: "Launchpad", bundle: nil)
            let secondVC = storyboard.instantiateViewController(identifier: "LaunchpadViewController")
            secondVC.modalPresentationStyle = .fullScreen
            secondVC.modalTransitionStyle = .crossDissolve
            self.present(secondVC, animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
