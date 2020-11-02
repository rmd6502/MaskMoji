//
//  SettingsTableViewController.swift
//  MaskMoji
//
//  Created by Robert on 10/30/20.
//  Copyright © 2020 Robert Diamond. All rights reserved.
//

import UIKit

protocol SettingsDelegate {
    func dismissSettings(_ sender : Any)
    func scanMasks()
    func setDisplayDuration(_ duration : TimeInterval)
    func handleAddEmoji()
}

struct Setting {
    let title : String
    let image : UIImage?
}

class SettingsTableViewController: UITableViewController {
    var settingsList = [
        Setting(title: "Find Masks", image: UIImage.init(systemName: "antenna.radiowaves.left.and.right")),
        Setting(title: "Set Display Duration",image: UIImage.init(systemName: "clock.arrow.circlepath")),
        Setting(title: "Exit", image: UIImage.init(systemName: "x.circle")),
        Setting(title: "Choose Emoji", image: UIImage.init(systemName: "keyboard"))
    ]
    var delegate : SettingsDelegate?
    
    let kSettingsCellIdentifier = "settingsCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: kSettingsCellIdentifier)
        
        self.tableView.backgroundColor = UIColor.secondarySystemBackground
        self.tableView.separatorStyle = .none

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return settingsList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kSettingsCellIdentifier, for: indexPath)

        cell.textLabel?.text = settingsList[indexPath.item].title
        cell.imageView?.image = settingsList[indexPath.item].image
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let title = settingsList[indexPath.item].title
        switch title {
        case "Find Masks":
            delegate?.scanMasks()
        case "Set Display Duration":
            delegate?.setDisplayDuration(10)
        case "Exit":
            delegate?.dismissSettings(self)
        case "Choose Emoji":
            delegate?.handleAddEmoji()
        default:
            delegate?.dismissSettings(self)
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
