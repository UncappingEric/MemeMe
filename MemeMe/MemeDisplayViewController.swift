//
//  MemeDisplayViewController.swift
//  MemeMe
//
//  Created by Eric Cajuste on 10/25/17.
//  Copyright © 2017 Cajuste. All rights reserved.
//

import Foundation
import UIKit

class MemeDisplayViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    var meme: Meme!
    
    override func viewDidLoad() {
        imageView.image = meme.meme
        imageView.contentMode = .scaleAspectFit
    }
}
