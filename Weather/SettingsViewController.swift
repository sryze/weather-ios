//
//  SettingsViewController.swift
//  Weather
//
//  Created by Sergey on 09/02/16.
//  Copyright © 2016 Sergey Zolotarev. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

    @IBOutlet weak var celsiusCell: UITableViewCell!
    @IBOutlet weak var farenheitCell: UITableViewCell!
    @IBOutlet weak var kelvinCell: UITableViewCell!

    override func viewDidLoad() {
        super.viewDidLoad()

        selectTemperatureUnitsCell(selectedCell: {
            switch Settings().temperatureScale {
                case .Celsius:
                    return celsiusCell
                case .Farenheit:
                    return farenheitCell
                default:
                    return kelvinCell
            }
        }())
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = super.tableView(super.tableView, cellForRowAt: indexPath)
        selectTemperatureUnitsCell(selectedCell: cell)

        Settings().temperatureScale = {
            switch cell {
                case celsiusCell:
                    return .Celsius
                case farenheitCell:
                    return .Farenheit
                default:
                    return .Kelvin
            }
        }()
    }

    private func selectTemperatureUnitsCell(selectedCell: UITableViewCell) {
        let temperatureScaleCells = [
            celsiusCell!,
            farenheitCell!,
            kelvinCell!
        ]
        for cell in temperatureScaleCells {
            cell.accessoryType = cell == selectedCell ? .checkmark : .none
        }
    }
}
