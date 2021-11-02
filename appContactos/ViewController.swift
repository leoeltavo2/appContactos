//
//  ViewController.swift
//  appContactos
//
//  Created by mac14 on 01/11/21.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    var obtenerIndex: Int?
    var obtenerNombre: String?
    var obtenerNumero: String?
    var obtenerDireccion: String?
    var obtenerImagen: UIImage?

    @IBOutlet weak var tablaContactos: UITableView!
    
    //MARK: - conexion a la BD
    let contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //MARK: - Arreglo de contactos
    var contactos = [Contacto]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //celda personalizada
        tablaContactos.register(UINib(nibName: "CeldaPersonalizada", bundle: nil), forCellReuseIdentifier: "celda")
        leerDatos()
        
        tablaContactos.delegate = self
        tablaContactos.dataSource = self
        
    }

    //MARK: - refrescar vista despues de regresar
    override func viewWillAppear(_ animated: Bool) {
        tablaContactos.reloadData()
    }
    
    @IBAction func btnAgregaContacto(_ sender: UIBarButtonItem) {
        
        let alerta = UIAlertController(title: "AGREGAR NUEVO CONTACTO", message: "Rellene los datos", preferredStyle: .alert)
        
        //textfields
        alerta.addTextField { (field) in
            field.placeholder = "Nombre"
            field.returnKeyType = .next
        }
        alerta.addTextField { (field) in
            field.placeholder = "Numero"
            field.returnKeyType = .next
            field.keyboardType = .numberPad
        }
        alerta.addTextField { (field) in
            field.placeholder = "Dirección"
            field.returnKeyType = .next
        }
        
        let Aceptar = UIAlertAction(title: "Aceptar", style: .default) { (_) in
                        
            guard let verificarNombre = alerta.textFields?[0].text, !verificarNombre.isEmpty,
                  let verificarNumero = alerta.textFields?[1].text, !verificarNumero.isEmpty,
                  let verificarDireccion = alerta.textFields?[2].text, !verificarDireccion.isEmpty else { return }
            
            //MARK: - crear contacto
            let nuevoContacto = Contacto(context: self.contexto)
            
            //asignar los valores
            nuevoContacto.nombre = verificarNombre
            nuevoContacto.telefono = Int64(verificarNumero) ?? 000
            nuevoContacto.direccion = verificarDireccion
            
            self.contactos.append(nuevoContacto)
            
            //MARK: - guardar contacto en la BD
            self.guardarContacto()
            //MARK: - recargar informacion
            self.tablaContactos.reloadData()
        }
        
        let cancelar = UIAlertAction(title: "Cancelar", style: .destructive)
        
        
        alerta.addAction(Aceptar)
        alerta.addAction(cancelar)
        
        present(alerta, animated: true)
        
    }
    
    //MARK: - Metodo guardar contacto
    func guardarContacto(){
        do {
            try contexto.save()
            print("Exito")
            
        } catch let error as NSError {
            print("Error al guardar el contacto \(error.localizedDescription)")
        }
    }
    
    //MARK: - Metodo Leer datos
    func leerDatos(){
        let fetchRequest: NSFetchRequest <Contacto> = Contacto.fetchRequest()
        
            do {
                contactos = try contexto.fetch(fetchRequest)
            } catch let error as NSError {
                print("Error al leer los datos \(error.localizedDescription)")
            }
    }
    
}

extension ViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactos.count
    }
    
    //MARK: - eliminar elemento de la tabla y BD
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        //eliminar elemento
        if editingStyle == .delete{
            contexto.delete(contactos[indexPath.row])
            contactos.remove(at: indexPath.row)
            guardarContacto()
        }
        tablaContactos.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celda = tablaContactos.dequeueReusableCell(withIdentifier: "celda", for:indexPath) as! CeldaPersonalizada
        celda.lblNombreContacto.text = contactos[indexPath.row].nombre
        celda.lblNumeroContacto.text = String(contactos[indexPath.row].telefono)
        celda.lblDireccion.text = contactos[indexPath.row].direccion
        celda.imagenContacto.image = UIImage(data: contactos[indexPath.row].imagenPerfil!)
        return celda
    }
    
    //SELECCIONAR UN ELEMENTO
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        obtenerNombre = contactos[indexPath.row].nombre
        obtenerNumero = String(contactos[indexPath.row].telefono)
        obtenerDireccion = contactos[indexPath.row].direccion
        obtenerImagen = UIImage(data: contactos[indexPath.row].imagenPerfil!)
        obtenerIndex = indexPath.row
        performSegue(withIdentifier: "segueEditarContacto", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueEditarContacto"{
            let objEditarContacto = segue.destination as! EditarContactoViewController
            objEditarContacto.recibirNombre = obtenerNombre
            objEditarContacto.recibirNumero = obtenerNumero
            objEditarContacto.recibirDireccion = obtenerDireccion
            objEditarContacto.recibirImagen = obtenerImagen
            
            //mandar posicion de la celda
            objEditarContacto.recibirIndex = obtenerIndex
        }
    }
    
}
