//
//  CeldaPersonalizada.swift
//  appContactos
//
//  Created by mac14 on 01/11/21.
//

import UIKit

class CeldaPersonalizada: UITableViewCell {

    @IBOutlet weak var imagenContacto: UIImageView!
    @IBOutlet weak var lblNombreContacto: UILabel!
    @IBOutlet weak var lblNumeroContacto: UILabel!
    @IBOutlet weak var lblDireccion: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        imagenContacto.layer.cornerRadius = imagenContacto.frame.size.width/2
        imagenContacto.clipsToBounds = true
        imagenContacto.layer.borderWidth = 1.5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
