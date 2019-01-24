//
//  ImagenesLugaresViewController.swift
//  CoreDataFinal
//
//  Created by Fernando Jt on 15/4/18.
//  Copyright © 2018 Fernando Jumbo Tandazo. All rights reserved.
//

import UIKit
import CoreData
class ImagenesLugaresViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,
UICollectionViewDelegate, UICollectionViewDataSource{

    var imagenLugar : Lugares!
    var id : Int16!
    var imagen : UIImage!
    var imagenes : [Imagenes] = []
    var refrescar : UIRefreshControl!
    
    @IBOutlet weak var coleccion: UICollectionView!
    
    func conexion() -> NSManagedObjectContext{
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.persistentContainer.viewContext
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        id = imagenLugar.id
        self.title = imagenLugar.nombre
        coleccion.delegate = self
        coleccion.dataSource = self
        
        let rightButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(accionCamara))
        self.navigationItem.rightBarButtonItem = rightButton
        
        let itemSize = UIScreen.main.bounds.width/3 - 3
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets.init(top: 20, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        layout.minimumInteritemSpacing = 3
        layout.minimumLineSpacing = 3
        coleccion.collectionViewLayout = layout
        
        llamarImagenes()
        
        refrescar = UIRefreshControl()
        coleccion.alwaysBounceVertical = true
        refrescar.tintColor = UIColor.green
        refrescar.addTarget(self, action: #selector(recargarDatos), for: .valueChanged)
        coleccion.addSubview(refrescar)
        
    }

    @objc func accionCamara(){
       let alerta = UIAlertController(title: "Cargar imagen", message: "Camara/Galeria", preferredStyle: .actionSheet)
        
        let accionCamara = UIAlertAction(title: "Tomar fotografia", style: .default) { (action) in
            self.tomarFotografia()
        }
        let accionGaleria = UIAlertAction(title: "Entrar a galeria", style: .default) { (action) in
            self.entrarGaleria()
        }
        
        let accionCancelar = UIAlertAction(title: "Cancelar", style: .destructive, handler: nil)
        
        alerta.addAction(accionCamara)
        alerta.addAction(accionGaleria)
        alerta.addAction(accionCancelar)
        
        present(alerta, animated: true, completion: nil)
    }//fin accion camara
    
    func tomarFotografia(){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func entrarGaleria(){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
        
    }
    
   
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        let imagenTomada = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage
        imagen = imagenTomada
        
        let contexto = conexion()
        let entityImagenes = NSEntityDescription.insertNewObject(forEntityName: "Imagenes", into: contexto) as! Imagenes
        let uuid = UUID()
        entityImagenes.id = uuid
        entityImagenes.id_lugares = id
        let imagenFinal = imagen.pngData() as Data?
        entityImagenes.imagenes = imagenFinal
        
        //relacion
        imagenLugar.mutableSetValue(forKey: "imagenes").add(entityImagenes)
        //
        
        do {
            try contexto.save()
            //self.llamarImagenes()
            //self.coleccion.reloadData()
            dismiss(animated: true, completion: nil)
            print("Guardó")
        } catch let error as NSError {
             print("No Guardó",error)
        }
        
       
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagenes.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = coleccion.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ImagenCollectionViewCell
        let imagen = imagenes[indexPath.row]
        if let imagen  = imagen.imagenes{
            cell.imagen.image = UIImage(data: imagen as Data)
        }
        return cell
    }
    
    func llamarImagenes(){
        let contexto = conexion()
        let fetchRequest : NSFetchRequest<Imagenes> = Imagenes.fetchRequest()
        let idLugar = String(id)
        fetchRequest.predicate = NSPredicate(format: "id_lugares == %@", idLugar)
        do {
            imagenes = try contexto.fetch(fetchRequest)
        } catch let error as NSError {
            print("no funciona",error)
        }
    }
    
    @objc func recargarDatos(){
        llamarImagenes()
        coleccion.reloadData()
        stop()
    }
    
    func stop(){
        refrescar.endRefreshing()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "imagen", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "imagen"{
            let id = sender as! NSIndexPath
            let fila = imagenes[id.row]
            let destino = segue.destination as! ImagenVistaViewController
            destino.imagenLugar = fila
        }
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
