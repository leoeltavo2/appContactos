//
//  EditarContactoViewController.swift
//  appContactos
//
//  Created by mac14 on 01/11/21.
//

import UIKit
import CoreData

class EditarContactoViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    //MARK: - conexion a la BD
    let contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //MARK: - Arreglo de contactos
    var contactos = [Contacto]()
    
    var recibirIndex: Int?
    var recibirNombre: String?
    var recibirNumero: String?
    var recibirDireccion: String?
    var recibirImagen: UIImage?
    
    @IBOutlet weak var imagenPerfilEditar: UIImageView!
    
    @IBOutlet weak var tfNombreEditar: UITextField!
    @IBOutlet weak var tfNumeroEditar: UITextField!
    @IBOutlet weak var tfDireccionEditar: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //propiedades de la imagen
        imagenPerfilEditar.layer.cornerRadius = imagenPerfilEditar.frame.size.width/2
        imagenPerfilEditar.clipsToBounds = true
        imagenPerfilEditar.layer.borderWidth = 8
        
        //leer datos de la BD
        leerDatos()
        
        //variables
        tfNombreEditar.text = recibirNombre
        tfNumeroEditar.text = recibirNumero
        tfNumeroEditar.keyboardType = .numberPad
        tfDireccionEditar.text = recibirDireccion
        imagenPerfilEditar.image = recibirImagen
        
        //MARK: - agregar la opcion de tab a la imagen
        let gesturaRecognized = UITapGestureRecognizer(target: self, action: #selector(clickImagen))
        gesturaRecognized.numberOfTapsRequired = 1
        gesturaRecognized.numberOfTouchesRequired = 1
        imagenPerfilEditar.addGestureRecognizer(gesturaRecognized)
        imagenPerfilEditar.isUserInteractionEnabled = true
    }
    
    //MARK: - metodo del clickImagen poniendo @objc por ser parte de ello
    @objc func clickImagen(gestura: UITapGestureRecognizer){
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true, completion: nil)
    }
    
    //MARK: - metodo seleccion de foto
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let userPickerImage = info[.editedImage] as? UIImage else {return}
        imagenPerfilEditar.image = userPickerImage
        
        //ocultar picker
        picker.dismiss(animated: true)
    }

    @IBAction func btnAceptar(_ sender: UIButton) {
        editarContacto()
    }
    
    
    @IBAction func btnCancelar(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    //Al darle click a cuaquier parte se oculta el teclado
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //MARK: - editar contacto BD
    func editarContacto(){
        do {
            let index = recibirIndex
            contactos[index!].setValue(tfNombreEditar.text, forKey: "nombre")
            contactos[index!].setValue(Int64(tfNumeroEditar.text!), forKey: "telefono")
            contactos[index!].setValue(tfDireccionEditar.text, forKey: "direccion")
            contactos[index!].setValue(imagenPerfilEditar.image?.pngData(), forKey: "imagenPerfil")
            try self.contexto.save()
        } catch {
            print("No se pudo editar \(error.localizedDescription)")
        }
    
        tfNombreEditar.text = ""
        tfNumeroEditar.text = ""
        tfDireccionEditar.text = ""
        navigationController?.popToRootViewController(animated: true)
    }
    
    //MARK: - leer datos de la BD
    func leerDatos(){
        let fetchRequest: NSFetchRequest <Contacto> = Contacto.fetchRequest()
        
            do {
                contactos = try contexto.fetch(fetchRequest)
            } catch let error as NSError {
                print("Error al leer los datos \(error.localizedDescription)")
            }
    }
    
    
    
}
