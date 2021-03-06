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
    let imagenPerson = UIImage(systemName: "person.fill")

    @IBOutlet weak var tablaContactos: UITableView!
    
    //MARK: - conexion a la BD
    let contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //MARK: - Arreglo de contactos
    var contactos = [Contacto]()
    
    //Buscador
    let controladorBusqueda = UISearchController(searchResultsController: nil)
    var filtrarContacto = [Contacto]()
    var isSearchBarEmpty: Bool {
        guard let text = controladorBusqueda.searchBar.text else {return false}
        return text.isEmpty
    }
    var isFiltering: Bool {
      return controladorBusqueda.isActive && !isSearchBarEmpty
    }

    
    //MARK: - VIEWDIDLOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //celda personalizada
        tablaContactos.register(UINib(nibName: "CeldaPersonalizada", bundle: nil), forCellReuseIdentifier: "celda")
        leerDatos()
        
        tablaContactos.delegate = self
        tablaContactos.dataSource = self
        
        //Buscador
        controladorBusqueda.searchResultsUpdater = self
        navigationItem.searchController = controladorBusqueda
        controladorBusqueda.obscuresBackgroundDuringPresentation = false
        controladorBusqueda.searchBar.placeholder = "Buscar contacto"
        navigationItem.searchController = controladorBusqueda
        definesPresentationContext = true
       
        
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
            field.placeholder = "Direcci??n"
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
        //comprobar si esta filtrando
        if isFiltering {
           return filtrarContacto.count
         }
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
        
        //comprobar el filtrado
        var contacto: Contacto
          if isFiltering {
            contacto = filtrarContacto[indexPath.row]
          } else {
            contacto  = contactos[indexPath.row]
          }
        
        celda.lblNombreContacto.text = contacto.nombre
        celda.lblNumeroContacto.text = String(contacto.telefono)
        celda.lblDireccion.text = contacto.direccion
        celda.imagenContacto.image = UIImage(data: (contacto.imagenPerfil ?? imagenPerson?.pngData())!)
        return celda
    }
    
    //SELECCIONAR UN ELEMENTO
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var contacto: Contacto
          if isFiltering {
            contacto = filtrarContacto[indexPath.row]
          } else {
            contacto  = contactos[indexPath.row]
          }
        
        obtenerNombre = contacto.nombre
        obtenerNumero = String(contacto.telefono)
        obtenerDireccion = contacto.direccion
        obtenerImagen = UIImage(data: (contacto.imagenPerfil ?? imagenPerson?.pngData())!)
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

//MARK: - buscador
extension ViewController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    
    func filterContentForSearchText(_ searchText: String) {
        filtrarContacto = contactos.filter( {(contact: Contacto) -> Bool in
            return (contact.nombre?.lowercased().contains(searchText.lowercased()))!
        })
      
      tablaContactos.reloadData()
    }

}
