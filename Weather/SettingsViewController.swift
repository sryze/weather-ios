//
//  SettingsViewController.swift
//  Weather
//
//  Created by Sergey on 09/02/16.
//  Copyright © 2016 Rhinoda. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    @IBOutlet weak var celsiusCell: UITableViewCell!
    @IBOutlet weak var farenheitCell: UITableViewCell!
    @IBOutlet weak var kelvinCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let temperatureUnits = NSUserDefaults.standardUserDefaults().stringForKey("TemperatureUnits") {
            self.selectTemperatureUnitsCell({
                switch temperatureUnits {
                    case "Celsius":
                        return self.celsiusCell
                    case "Farenheit":
                        return self.farenheitCell
                    default:
                        return self.kelvinCell
                }
            }())
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = super.tableView(super.tableView, cellForRowAtIndexPath: indexPath)
        self.selectTemperatureUnitsCell(cell)
        
        let temperatureUnits: String = {
            switch cell {
                case self.celsiusCell:
                    return "Celsius"
                case self.farenheitCell:
                    return "Farenheit"
                default:
                    return "Kelvin"
            }
        }()
        NSUserDefaults.standardUserDefaults().setValue(temperatureUnits, forKey: "TemperatureUnits")
    }
    
    private func selectTemperatureUnitsCell(selectedCell: UITableViewCell) {
        let temperatureUnitCells = [
            self.celsiusCell!,
            self.farenheitCell!,
            self.kelvinCell!
        ]
        for cell in temperatureUnitCells {
            cell.accessoryType = cell == selectedCell ? .Checkmark : .None
        }
    }
}
