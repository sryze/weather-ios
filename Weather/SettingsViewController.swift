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
        
        self.selectTemperatureUnitsCell({
            switch Settings().temperatureScale {
                case .Celsius:
                    return self.celsiusCell
                case .Farenheit:
                    return self.farenheitCell
                default:
                    return self.kelvinCell
            }
        }())
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = super.tableView(super.tableView, cellForRowAtIndexPath: indexPath)
        self.selectTemperatureUnitsCell(cell)
        
        Settings().temperatureScale = {
            switch cell {
                case self.celsiusCell:
                    return .Celsius
                case self.farenheitCell:
                    return .Farenheit
                default:
                    return .Kelvin
            }
        }()
    }
    
    private func selectTemperatureUnitsCell(selectedCell: UITableViewCell) {
        let temperatureScaleCells = [
            self.celsiusCell!,
            self.farenheitCell!,
            self.kelvinCell!
        ]
        for cell in temperatureScaleCells {
            cell.accessoryType = cell == selectedCell ? .Checkmark : .None
        }
    }
}
