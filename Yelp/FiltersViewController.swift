//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Dave Vo on 9/3/15.
//  Copyright (c) 2015 Chau Vo. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate {
    optional func filtersViewController(filFiltersViewController: FiltersViewController, didUpdateFilters filters: [String:AnyObject])
}

class FiltersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SwitchCellDelegate, DropDownCellDelegate {
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var tableView: UITableView!
    weak var delegate: FiltersViewControllerDelegate?
    
    var categories: [[String: String]]!
    var switchStates = [Int:Bool]()
    var radii: [Float?]!
    var filters = [String : AnyObject]()
    
    var isSortCollapsed = true
    var isRadiusCollapsed = true
    var isCategoryCollapsed = true
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categories = yelpCategories()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        // (miles)
        radii = [nil, 0.3, 1, 5, 20]
        
        
        // Get old states
        var switchStatesData = defaults.objectForKey("switchStates") as? NSData
        if let switchStatesData = switchStatesData {
            switchStates = NSKeyedUnarchiver.unarchiveObjectWithData(switchStatesData) as! [Int:Bool]
        }
        
        var filtersData = defaults.objectForKey("filters") as? NSData
        if let filtersData = filtersData {
            filters = NSKeyedUnarchiver.unarchiveObjectWithData(filtersData) as! [String : AnyObject]
        }
        
        if filters["sort"] == nil {
            filters["sort"] = NSNumber(unsignedInteger: 0)
        }
        
        self.tableView.tableFooterView = UIView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Button
    
    @IBAction func onCancelButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onSearchButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
        
        
        var selectedCategories = [String]()
        for (row, isSelected) in switchStates {
            if isSelected {
                selectedCategories.append(categories[row]["code"]!)
            }
        }
        if selectedCategories.count > 0 {
            filters["categories"] = selectedCategories
        } else {
            filters["categories"] = nil
        }
        
        delegate?.filtersViewController?(self, didUpdateFilters: filters)
        
        // Save to NSUserDefaults
        var switchStatesData = NSKeyedArchiver.archivedDataWithRootObject(switchStates)
        self.defaults.setObject(switchStatesData, forKey: "switchStates")
        
        var filtersData = NSKeyedArchiver.archivedDataWithRootObject(filters)
        self.defaults.setObject(filtersData, forKey: "filters")
        
        defaults.synchronize()
    }
    
    
    
    // MARK: Table view
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return radii.count
        case 2:
            return 3
        case 3:
            return categories.count + 1
        default:
            break
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            // Deal area
            
            let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
            
            cell.switchLabel.text = "Offering a Deal"
            cell.delegate = self
            
            cell.onSwitch.on = filters["deal"] as? Bool ?? false
            
            return cell
            
        case 1:
            // Radius area
            
            let cell = tableView.dequeueReusableCellWithIdentifier("DropDownCell", forIndexPath: indexPath) as! DropDownCell
            cell.delegate = self
            
            // Set label for each cell
            if indexPath.row == 0 {
                cell.label.text = "Auto"
            } else {
                if radii[indexPath.row] == 1 {
                    cell.label.text =  String(format: "%g", radii[indexPath.row]!) + " mile"
                } else {
                    cell.label.text =  String(format: "%g", radii[indexPath.row]!) + " miles"
                }
                
            }
            
            setRadiusIcon(indexPath.row, iconView: cell.iconView)
            setRadiusCellVisible(indexPath.row, cell: cell)
            
            return cell
            
        case 2:
            // Sort area
            
            let cell = tableView.dequeueReusableCellWithIdentifier("DropDownCell", forIndexPath: indexPath) as! DropDownCell
            cell.delegate = self
            
            switch indexPath.row {
            case 0:
                cell.label.text = "Best Match"
                break
            case 1:
                cell.label.text = "Distance"
                break
            case 2:
                cell.label.text = "Rating"
                break
            default:
                break
                
            }
            
            setSortIcon(indexPath.row, iconView: cell.iconView)
            setSortCellVisible(indexPath.row, cell: cell)
            
            return cell
            
        case 3:
            // Category area
            
            if indexPath.row != categories.count {
                let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
                
                cell.switchLabel.text = categories[indexPath.row]["name"]
                cell.delegate = self
                
                cell.onSwitch.on = switchStates[indexPath.row] ?? false
                
                setCategoryCellVisible(indexPath.row, cell: cell)
                return cell
            } else {
                // This is the last row
                let cell = tableView.dequeueReusableCellWithIdentifier("SeeAllCell", forIndexPath: indexPath) as! SeeAllCell
                
                let tapSeeAllCell = UITapGestureRecognizer(target: self, action: "tapSeeAll:")
                cell.addGestureRecognizer(tapSeeAllCell)
                
                
                return cell
            }
            
        default:
            let cell = UITableViewCell()
            return cell
        }
        

    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        var headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        headerView.backgroundColor = UIColor(red: 250/255, green: 234/255, blue: 234/255, alpha: 1)
        
        var titleLabel = UILabel(frame: CGRect(x: 15, y: 15, width: 320, height: 30))
        titleLabel.textColor = UIColor(red: 190/255, green: 38/255, blue: 37/255, alpha: 1.0)
        titleLabel.font = UIFont(name: "Helvetica", size: 15)
        
        
        switch section {
        case 0:
            titleLabel.text = "Deal"
            break
        case 1:
            titleLabel.text = "Distance"
            break
        case 2:
            titleLabel.text = "Sort By"
            break
        case 3:
            titleLabel.text = "Category"
            break

        default:
            return nil
        }
        
        headerView.addSubview(titleLabel)
        
        return headerView
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 1:
            if isRadiusCollapsed {
                let radiusValue = filters["radius"] as! Float?
                if radiusValue != radii[indexPath.row] {
                    return 0
                }
            }
            break
        case 2:
            if isSortCollapsed {
                let sortValue = getSortValue()
                if sortValue != indexPath.row {
                    return 0
                }
            }
            break
        case 3:
            if isCategoryCollapsed {
                if indexPath.row > 2 && indexPath.row != categories.count {
                    return 0
                }
            }
            break
        default:
            break
        }
        
        return 35.0
    }
    
    // MARK: Radius area
    
    func setRadiusIcon(row: Int, iconView: UIImageView) {
        let radiusValue = filters["radius"] as! Float?
        
        if radiusValue == radii[row] {
            if isRadiusCollapsed {
                iconView.image = UIImage(named: "Arrow")
            } else {
                iconView.image = UIImage(named: "Tick")
            }
            return
        }
        
        iconView.image = UIImage(named: "Circle")
    }
    
    func setRadiusCellVisible(row: Int, cell: DropDownCell) {
        let radiusValue = filters["radius"] as! Float?
        if isRadiusCollapsed && radii[row] != radiusValue {
            cell.label.hidden = true
            cell.iconView.hidden = true
            return
        }
        
        cell.label.hidden = false
        cell.iconView.hidden = false
    }
    
    // MARK: Sort area
    
    func getSortValue() -> Int {
        let sortValue = filters["sort"] as? Int
        
        if sortValue != nil {
            return sortValue!
        } else {
            return 0
        }
    }
    
    func setSortIcon(row: Int, iconView: UIImageView) {
        let sortValue = getSortValue()
        
        if sortValue == row {
            if isSortCollapsed {
                iconView.image = UIImage(named: "Arrow")
            } else {
                iconView.image = UIImage(named: "Tick")
            }
            return
        }
        
        iconView.image = UIImage(named: "Circle")
    }
    
    func setSortCellVisible(row: Int, cell: DropDownCell) {
        let sortValue = getSortValue()
        if isSortCollapsed && row != sortValue {
            cell.label.hidden = true
            cell.iconView.hidden = true
            return
        }
        
        cell.label.hidden = false
        cell.iconView.hidden = false
    }
    
    // MARK: Category area
    
    func setCategoryCellVisible(row: Int, cell: SwitchCell) {
        if isCategoryCollapsed && row > 2 && row != categories.count {
            cell.switchLabel.hidden = true
            cell.onSwitch.hidden = true
            return
        }
        
        cell.switchLabel.hidden = false
        cell.onSwitch.hidden = false
    }
    
    func tapSeeAll(sender:UITapGestureRecognizer) {
        // Get SeeAllCell
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: categories.count, inSection: 3)) as! SeeAllCell
        
        if cell.label.text == "See All" {
            cell.label.text = "Collapse"
            isCategoryCollapsed = false
        } else {
            cell.label.text = "See All"
            isCategoryCollapsed = true
        }
        
        tableView.reloadData()
    }
    
    // MARK: Implement delegate
    
    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPathForCell(switchCell)!

        if indexPath.section == 0 {
            self.filters["deal"] = value
        } else if indexPath.section == 3 {
            switchStates[indexPath.row] = value
        }
    }
    
    func selectCell(dropDownCell: DropDownCell, didSelect currentImg: UIImage) {
        let indexPath = tableView.indexPathForCell(dropDownCell)
        
        
        if indexPath != nil {
            if indexPath!.section == 1 {
                // Radius area
                switch currentImg {
                case UIImage(named: "Arrow")!:
                    isRadiusCollapsed = false
                    break
                case UIImage(named: "Tick")!:
                    isRadiusCollapsed = true
                    break
                case UIImage(named: "Circle")!:
                    filters["radius"] = radii[indexPath!.row]
                    isRadiusCollapsed = true
                    break
                default:
                    break
                }
            } else if indexPath!.section == 2 {
                // Sort area
                switch currentImg {
                case UIImage(named: "Arrow")!:
                    isSortCollapsed = false
                    break
                case UIImage(named: "Tick")!:
                    isSortCollapsed = true
                    break
                case UIImage(named: "Circle")!:
                    filters["sort"] = NSNumber(unsignedInteger: indexPath!.row)
                    isSortCollapsed = true
                    break
                default:
                    break
                }
            }
            
            tableView.reloadData()
        }
        
        
        
        
    }
    
    // MARK: List of Categories
    
    func yelpCategories() -> [[String: String]] {
        return [["name" : "Afghan", "code": "afghani"],
            ["name" : "African", "code": "african"],
            ["name" : "American, New", "code": "newamerican"],
            ["name" : "American, Traditional", "code": "tradamerican"],
            ["name" : "Arabian", "code": "arabian"],
            ["name" : "Argentine", "code": "argentine"],
            ["name" : "Armenian", "code": "armenian"],
            ["name" : "Asian Fusion", "code": "asianfusion"],
            ["name" : "Asturian", "code": "asturian"],
            ["name" : "Australian", "code": "australian"],
            ["name" : "Austrian", "code": "austrian"],
            ["name" : "Baguettes", "code": "baguettes"],
            ["name" : "Bangladeshi", "code": "bangladeshi"],
            ["name" : "Barbeque", "code": "bbq"],
            ["name" : "Basque", "code": "basque"],
            ["name" : "Bavarian", "code": "bavarian"],
            ["name" : "Beer Garden", "code": "beergarden"],
            ["name" : "Beer Hall", "code": "beerhall"],
            ["name" : "Beisl", "code": "beisl"],
            ["name" : "Belgian", "code": "belgian"],
            ["name" : "Bistros", "code": "bistros"],
            ["name" : "Black Sea", "code": "blacksea"],
            ["name" : "Brasseries", "code": "brasseries"],
            ["name" : "Brazilian", "code": "brazilian"],
            ["name" : "Breakfast & Brunch", "code": "breakfast_brunch"],
            ["name" : "British", "code": "british"],
            ["name" : "Buffets", "code": "buffets"],
            ["name" : "Bulgarian", "code": "bulgarian"],
            ["name" : "Burgers", "code": "burgers"],
            ["name" : "Burmese", "code": "burmese"],
            ["name" : "Cafes", "code": "cafes"],
            ["name" : "Cafeteria", "code": "cafeteria"],
            ["name" : "Cajun/Creole", "code": "cajun"],
            ["name" : "Cambodian", "code": "cambodian"],
            ["name" : "Canadian", "code": "New)"],
            ["name" : "Canteen", "code": "canteen"],
            ["name" : "Caribbean", "code": "caribbean"],
            ["name" : "Catalan", "code": "catalan"],
            ["name" : "Chech", "code": "chech"],
            ["name" : "Cheesesteaks", "code": "cheesesteaks"],
            ["name" : "Chicken Shop", "code": "chickenshop"],
            ["name" : "Chicken Wings", "code": "chicken_wings"],
            ["name" : "Chilean", "code": "chilean"],
            ["name" : "Chinese", "code": "chinese"],
            ["name" : "Comfort Food", "code": "comfortfood"],
            ["name" : "Corsican", "code": "corsican"],
            ["name" : "Creperies", "code": "creperies"],
            ["name" : "Cuban", "code": "cuban"],
            ["name" : "Curry Sausage", "code": "currysausage"],
            ["name" : "Cypriot", "code": "cypriot"],
            ["name" : "Czech", "code": "czech"],
            ["name" : "Czech/Slovakian", "code": "czechslovakian"],
            ["name" : "Danish", "code": "danish"],
            ["name" : "Delis", "code": "delis"],
            ["name" : "Diners", "code": "diners"],
            ["name" : "Dumplings", "code": "dumplings"],
            ["name" : "Eastern European", "code": "eastern_european"],
            ["name" : "Ethiopian", "code": "ethiopian"],
            ["name" : "Fast Food", "code": "hotdogs"],
            ["name" : "Filipino", "code": "filipino"],
            ["name" : "Fish & Chips", "code": "fishnchips"],
            ["name" : "Fondue", "code": "fondue"],
            ["name" : "Food Court", "code": "food_court"],
            ["name" : "Food Stands", "code": "foodstands"],
            ["name" : "French", "code": "french"],
            ["name" : "French Southwest", "code": "sud_ouest"],
            ["name" : "Galician", "code": "galician"],
            ["name" : "Gastropubs", "code": "gastropubs"],
            ["name" : "Georgian", "code": "georgian"],
            ["name" : "German", "code": "german"],
            ["name" : "Giblets", "code": "giblets"],
            ["name" : "Gluten-Free", "code": "gluten_free"],
            ["name" : "Greek", "code": "greek"],
            ["name" : "Halal", "code": "halal"],
            ["name" : "Hawaiian", "code": "hawaiian"],
            ["name" : "Heuriger", "code": "heuriger"],
            ["name" : "Himalayan/Nepalese", "code": "himalayan"],
            ["name" : "Hong Kong Style Cafe", "code": "hkcafe"],
            ["name" : "Hot Dogs", "code": "hotdog"],
            ["name" : "Hot Pot", "code": "hotpot"],
            ["name" : "Hungarian", "code": "hungarian"],
            ["name" : "Iberian", "code": "iberian"],
            ["name" : "Indian", "code": "indpak"],
            ["name" : "Indonesian", "code": "indonesian"],
            ["name" : "International", "code": "international"],
            ["name" : "Irish", "code": "irish"],
            ["name" : "Island Pub", "code": "island_pub"],
            ["name" : "Israeli", "code": "israeli"],
            ["name" : "Italian", "code": "italian"],
            ["name" : "Japanese", "code": "japanese"],
            ["name" : "Jewish", "code": "jewish"],
            ["name" : "Kebab", "code": "kebab"],
            ["name" : "Korean", "code": "korean"],
            ["name" : "Kosher", "code": "kosher"],
            ["name" : "Kurdish", "code": "kurdish"],
            ["name" : "Laos", "code": "laos"],
            ["name" : "Laotian", "code": "laotian"],
            ["name" : "Latin American", "code": "latin"],
            ["name" : "Live/Raw Food", "code": "raw_food"],
            ["name" : "Lyonnais", "code": "lyonnais"],
            ["name" : "Malaysian", "code": "malaysian"],
            ["name" : "Meatballs", "code": "meatballs"],
            ["name" : "Mediterranean", "code": "mediterranean"],
            ["name" : "Mexican", "code": "mexican"],
            ["name" : "Middle Eastern", "code": "mideastern"],
            ["name" : "Milk Bars", "code": "milkbars"],
            ["name" : "Modern Australian", "code": "modern_australian"],
            ["name" : "Modern European", "code": "modern_european"],
            ["name" : "Mongolian", "code": "mongolian"],
            ["name" : "Moroccan", "code": "moroccan"],
            ["name" : "New Zealand", "code": "newzealand"],
            ["name" : "Night Food", "code": "nightfood"],
            ["name" : "Norcinerie", "code": "norcinerie"],
            ["name" : "Open Sandwiches", "code": "opensandwiches"],
            ["name" : "Oriental", "code": "oriental"],
            ["name" : "Pakistani", "code": "pakistani"],
            ["name" : "Parent Cafes", "code": "eltern_cafes"],
            ["name" : "Parma", "code": "parma"],
            ["name" : "Persian/Iranian", "code": "persian"],
            ["name" : "Peruvian", "code": "peruvian"],
            ["name" : "Pita", "code": "pita"],
            ["name" : "Pizza", "code": "pizza"],
            ["name" : "Polish", "code": "polish"],
            ["name" : "Portuguese", "code": "portuguese"],
            ["name" : "Potatoes", "code": "potatoes"],
            ["name" : "Poutineries", "code": "poutineries"],
            ["name" : "Pub Food", "code": "pubfood"],
            ["name" : "Rice", "code": "riceshop"],
            ["name" : "Romanian", "code": "romanian"],
            ["name" : "Rotisserie Chicken", "code": "rotisserie_chicken"],
            ["name" : "Rumanian", "code": "rumanian"],
            ["name" : "Russian", "code": "russian"],
            ["name" : "Salad", "code": "salad"],
            ["name" : "Sandwiches", "code": "sandwiches"],
            ["name" : "Scandinavian", "code": "scandinavian"],
            ["name" : "Scottish", "code": "scottish"],
            ["name" : "Seafood", "code": "seafood"],
            ["name" : "Serbo Croatian", "code": "serbocroatian"],
            ["name" : "Signature Cuisine", "code": "signature_cuisine"],
            ["name" : "Singaporean", "code": "singaporean"],
            ["name" : "Slovakian", "code": "slovakian"],
            ["name" : "Soul Food", "code": "soulfood"],
            ["name" : "Soup", "code": "soup"],
            ["name" : "Southern", "code": "southern"],
            ["name" : "Spanish", "code": "spanish"],
            ["name" : "Steakhouses", "code": "steak"],
            ["name" : "Sushi Bars", "code": "sushi"],
            ["name" : "Swabian", "code": "swabian"],
            ["name" : "Swedish", "code": "swedish"],
            ["name" : "Swiss Food", "code": "swissfood"],
            ["name" : "Tabernas", "code": "tabernas"],
            ["name" : "Taiwanese", "code": "taiwanese"],
            ["name" : "Tapas Bars", "code": "tapas"],
            ["name" : "Tapas/Small Plates", "code": "tapasmallplates"],
            ["name" : "Tex-Mex", "code": "tex-mex"],
            ["name" : "Thai", "code": "thai"],
            ["name" : "Traditional Norwegian", "code": "norwegian"],
            ["name" : "Traditional Swedish", "code": "traditional_swedish"],
            ["name" : "Trattorie", "code": "trattorie"],
            ["name" : "Turkish", "code": "turkish"],
            ["name" : "Ukrainian", "code": "ukrainian"],
            ["name" : "Uzbek", "code": "uzbek"],
            ["name" : "Vegan", "code": "vegan"],
            ["name" : "Vegetarian", "code": "vegetarian"],
            ["name" : "Venison", "code": "venison"],
            ["name" : "Vietnamese", "code": "vietnamese"],
            ["name" : "Wok", "code": "wok"],
            ["name" : "Wraps", "code": "wraps"],
            ["name" : "Yugoslav", "code": "yugoslav"]]
    }

    
    

    
}
