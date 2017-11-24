//
//  ClassificationViewController.swift
//  SimpleCoreMLExample
//
//  Created by Birapuram Kumar Reddy on 11/19/17.
//  Copyright © 2017 KRSimpleApps. All rights reserved.
//

import UIKit
import Vision

class ClassificationViewController: UIViewController,UITableViewDataSource {

    internal var classificationObservations:[VNClassificationObservation]!
    @IBOutlet weak var tableview: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableview.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*func createClassificationResults() {
        if let observations = classificationObservations {
            for observation in observations {
                classificationResults[observation.identifier] = observation.confidence
            }
        }
    }*/

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classificationObservations.count;
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "classificationCell", for: indexPath) as! ClassificationCell
        let observation = classificationObservations[indexPath.row]
        cell.configureCell(label: observation.identifier, percentage: observation.confidence)
        return cell
    }
}

