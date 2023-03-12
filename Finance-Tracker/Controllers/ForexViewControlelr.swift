//
//  ForexViewControlelr.swift
//  Finance-Tracker
//
//  Created by Petar Iliev on 11.3.23.
//

import UIKit

class ForexViewControlelr: UITableViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    
    var forexManager: ForexManager = ForexManager()
    var forexRates: [ForexRate] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: K.assetCellIdentifier, bundle: nil), forCellReuseIdentifier: K.assetCellIdentifier)
        
        forexManager.delegate = self
        forexManager.performRequest()
    }
    
    

    // MARK: - Table View methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forexRates.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.assetCellIdentifier, for: indexPath) as! AssetCell
        let currentForex: ForexRate = forexRates[indexPath.row]
        cell.stockLabel.text = currentForex.shortsymbol
        cell.companyLabel.text = currentForex.name
        cell.priceLabel.text = Utilities.formatPriceLabel(currentForex.last, with: "")
        cell.percentLabel.text = ""
        cell.logoImaeView.image = UIImage(named: "Forex/\(currentForex.shortsymbol).png")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - ForexManager Delegate methods
extension ForexViewControlelr: ForexManagerDelegate {
    
    func didReceiveForexData(with data: [ForexRate]) {
        forexRates = data
        fixRates()
        forexRates.append(ForexRate(shortsymbol: "USD", last: "1.00", name: "US Dollar"))
        forexRates = forexRates.sorted { rate1, rate2 in
            return rate1.shortsymbol < rate2.shortsymbol
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
}

// MARK: - Helper methods
extension ForexViewControlelr {
    
    // Fixes the API response
    func fixRates() {
        for forexRate in forexRates {
            if let newName = getName(for: String(forexRate.shortsymbol.dropFirst(3))) {
                forexRate.name = newName
            } else {
                forexRate.name = String(forexRate.name.dropFirst(10))
            }
            forexRate.shortsymbol = String(forexRate.shortsymbol.dropFirst(3))
        }
    }
    
    // Returns the name of the given currency symbol
    func getName(for symbol: String) -> String? {
        switch symbol {
        case "AOA":
            return "Angolan Kwanza"
        case "AWG":
            return "Arubian Guilder"
        case "BTN":
            return "Bhutanese Ngultrum"
        case "CDF":
            return "Congolais Franc"
        case "GEL":
            return "Congolais Franc"
        case "GHS":
            return "Ghanaian Cedi"
        case "KGS":
            return "Kyrgystani Som"
        case "SDG":
            return "Sudanese Pound"
        case "TJS":
            return "Tajikistani Somoni"
        case "TMT":
            return "Turkmenistani Manat"
        case "UZS":
            return "Uzbekistani Som"
        case "RSD":
            return "Serbian Dinar"
        case "ZMW":
            return "Zambian Kwacha"
        default:
            return nil
        }
    }
    
}
