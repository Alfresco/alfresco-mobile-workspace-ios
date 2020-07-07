//
//  AlfrescoNodeCollectionViewCell.swift
//  ContentApp
//
//  Created by Florin Baincescu on 06/07/2020.
//  Copyright © 2020 Florin Baincescu. All rights reserved.
//

import UIKit

class AlfrescoNodeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    var node: AlfrescoNode? {
        didSet {
            if let node = node {
                title.text = node.title
                subtitle.text = node.path
                iconImageView.image = FileIcon.icon(for: node.mimeType)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func moreButtonTapped(_ sender: UIButton) {
    }
}
