//
//  ClassificationCell.swift
//  SimpleCoreMLExample
//
//  Created by Birapuram Kumar Reddy on 11/19/17.
//  Copyright © 2017 KRSimpleApps. All rights reserved.
//

import UIKit

class ClassificationCell: UITableViewCell {

    @IBOutlet weak var classificationLabel: UILabel!
    @IBOutlet weak var classificationPercentage: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(label:String,percentage:Float) {
        self.classificationLabel.text = label
        self.classificationPercentage.text = String(percentage)
    }

}
