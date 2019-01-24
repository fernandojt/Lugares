//
//  ViewController.swift
//  CoreDataFinal
//
//  Created by Fernando Jt on 15/4/18.
//  Copyright © 2018 Fernando Jumbo Tandazo. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var tabla: UITableView!
    var lugares : [Lugares] = []
    
    var fetchResultController : NSFetchedResultsController<Lugares>!
    
    func conexion() -> NSManagedObjectContext{
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.persistentContainer.viewContext
    }


    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabla.delegate = self
        tabla.dataSource = self
        
        let contexto = conexion()
        
        let fetchRequest : NSFetchRequest<Lugares> = Lugares.fetchRequest()
        
        let orderByNombre = NSSortDescriptor(key: "nombre", ascending: true)
        fetchRequest.sortDescriptors = [orderByNombre]
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: contexto, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchResultController.delegate = self
        
        do {
            try fetchResultController.performFetch()
            lugares = fetchResultController.fetchedObjects!
        } catch let error as NSError {
            print("hubo un error", error)
        }

    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lugares.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tabla.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let lugar = lugares[indexPath.row]
        cell.textLabel?.text = lugar.nombre
        cell.detailTextLabel?.text = lugar.descripcion
        return cell
    }
    
    //fetchedResultControllerDelegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tabla.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tabla.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            self.tabla.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            self.tabla.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            self.tabla.reloadRows(at: [indexPath!], with: .fade)
        default:
            self.tabla.reloadData()
        }
        self.lugares = controller.fetchedObjects as! [Lugares]
    }


    //editActions
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let botonBorrar = UITableViewRowAction(style: .destructive, title: "Borrar") { (action, indexPath) in
            let contexto = self.conexion()
            let borrar = self.fetchResultController.object(at: indexPath)
            contexto.delete(borrar)
            
            do{
                try contexto.save()
            }catch{
                print("Error al borrar")
            }
        }//fin boton borrar
        
        let botonMapa = UITableViewRowAction(style: .default, title: "mapa") { (action, indexPath) in
            //print("ver mapa")
            self.performSegue(withIdentifier: "mapa", sender: indexPath)
        }
        botonMapa.backgroundColor = UIColor.darkGray
        let botonEditar = UITableViewRowAction(style: .normal, title: "Editar") { (action, indexPath) in
            print("Editar")
        }
        
        
        return [botonBorrar,botonMapa,botonEditar]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "imagenes", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "imagenes"{
            if let id = tabla.indexPathForSelectedRow{
                let fila = lugares[id.row]
                let destino = segue.destination as! ImagenesLugaresViewController
                destino.imagenLugar = fila
            }
        }
        
        if segue.identifier == "mapa"{
            let id = sender as! NSIndexPath
            let fila = lugares[id.row]
            let destino = segue.destination as! MapaViewController
            destino.coordLugares = fila
        }
    }
    
    
}

