//
//  ViewController.swift
//  NetStatusDemo
//
//  Created by Gabriel Theodoropoulos.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - IBOutlet Properties
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var monitorButton: UIButton!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        configureTableView()
        monitorButton.layer.cornerRadius = 15.0
        
        NetStatus.shared.didStartMonitoringHandler = { [weak self] in
            self?.monitorButton.setTitle("Stop Monitoring", for: .normal)
        }
        
        NetStatus.shared.didStopMonitoringHandler = { [weak self] in
            self?.monitorButton.setTitle("Start Monitoring", for: .normal)
            self?.tableView.reloadData()
        }
        
        NetStatus.shared.netStatusChangeMonitoring = {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }

    
    // MARK: - Custom Methods
    
    func configureTableView() {
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.isScrollEnabled = false
        tableView.alwaysBounceVertical = false
        tableView.backgroundColor = UIColor.clear
        tableView.isScrollEnabled = true
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.register(UINib(nibName: "InfoCell", bundle: nil), forCellReuseIdentifier: "infoCell")
    }

    
    // MARK: - IBAction Methods
    
    @IBAction func toggleMonitoring(_ sender: Any) {
        if NetStatus.shared.isMonitoring {
            NetStatus.shared.stopMonitoring()
        } else {
            NetStatus.shared.startMonitoring()
        }
    }
}



// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section != 1 ? 1 : NetStatus.shared.availableInterfaceTypes?.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Connected"
        case 1: return "Interface Types"
        case 2: return "Is Expensive"
        default: return nil
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath) as! InfoCell
        
        switch indexPath.section {
        case 0:
            cell.label.text = NetStatus.shared.isConnected ? "Connected" : "Not Connected"
            cell.indicationImageView.image = NetStatus.shared.isConnected ? UIImage(named: "checkmark") : UIImage(named: "delete")
        case 1:
            if let interfaceType = NetStatus.shared.availableInterfaceTypes?[indexPath.row] {
                cell.label.text = "\(interfaceType)"
                
                if let currentInterfaceType = NetStatus.shared.interfaceType {
                    cell.indicationImageView.image = (currentInterfaceType == interfaceType) ? UIImage(named: "checkmark") : UIImage(named: "delete")
                }
            }
        case 2:
            cell.label.text = (NetStatus.shared.isExpensive) ? "Is Expensive" : "Not Expensive"
            cell.indicationImageView.image = (NetStatus.shared.isExpensive) ? UIImage(named: "checkmark") : UIImage(named: "delete")
        default:
            break
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
}
