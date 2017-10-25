//
//  MemeTableViewController.swift
//  MemeMe
//
//  Created by Eric Cajuste on 10/25/17.
//  Copyright © 2017 Cajuste. All rights reserved.
//

import Foundation
import UIKit

class MemeTableViewController: UITableViewController {
    
    var memes = [Meme]()
    
    override func viewWillAppear(_ animated: Bool) {
        memes = (UIApplication.shared.delegate as! AppDelegate).memes
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let meme = memes[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemeTableCell")!
        cell.detailTextLabel?.text = meme.top + " " + meme.bottom
        cell.imageView?.image = meme.meme
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "MemeDisplayViewController") as! MemeDisplayViewController
        controller.meme = memes[indexPath.row]
        
        navigationController?.pushViewController(controller, animated: true)
        
    }
    
    @IBAction func newMeme() {
        let controller = storyboard?.instantiateViewController(withIdentifier: "MemeEditorViewController") as! MemeEditorViewController
        present(controller, animated: true, completion: nil)
    }
    
}
