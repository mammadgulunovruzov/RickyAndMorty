//
//  CharacterCell.swift
//  RickyAndMorty
//
//  Created by Mammadgulu Novruzov on 15.04.25.
//

import UIKit

class CharacterCell: UITableViewCell {
    
    @IBOutlet var charachterImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var statusSpeciesLabel: UILabel!
    @IBOutlet var lastLocationLabel: UILabel!
    @IBOutlet var firstSeenLocationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = UIColor.surface
        contentView.layer.cornerRadius = 18
        contentView.layer.masksToBounds = true
        backgroundColor = .clear
        
        charachterImageView.contentMode = .scaleAspectFill
        charachterImageView.layer.cornerRadius = 8
        charachterImageView.clipsToBounds = true
        
        nameLabel.textColor = UIColor.textLabel
        statusSpeciesLabel.textColor = .textLabel
        lastLocationLabel.textColor = .textLabel
        firstSeenLocationLabel.textColor = .textLabel
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let inset: CGFloat = 14
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: inset, left: 0, bottom: inset, right: 0))
        
        
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    
}
