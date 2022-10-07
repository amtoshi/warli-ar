//
//  ViewController.swift
//  Warli AR
//
//  Created by Ashutosh Mane on 11/06/22.
//

import UIKit
import RealityKit
import ARKit

class ViewController: UIViewController{
    
    @IBOutlet var arView: ARView!
    @IBOutlet var addElementButton:UIButton!
    var arCoachingOverlay:ARCoachingOverlayView!
    var modelToBeAdded:String?
    
    
    override func viewDidLoad() {
        self.setupARView()
        super.viewDidLoad()
        setupAddElementButton()
        setupArCoachingOverlay(on: self.arView)
        #warning("setupResetButton()")
        
        // Add the box anchor to the scene
        
        
    }
    
    //MARK: setting up the ARenvironment
    
    func setupARView() {
        arView.automaticallyConfigureSession=false
        let configuration=ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        configuration.environmentTexturing = .automatic
        arView.session.run(configuration)
        arView.session.delegate=self
        self.arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.raycastForPlane(recognizer:))))
        
    }
    
    //POP Over button for adding new element
    
    func setupAddElementButton(){
        
        let addElement={(action:UIAction) in
            let elementName=action.title
            self.modelToBeAdded = elementName
            print(self.modelToBeAdded)
            
            
        }
        
        addElementButton.menu=UIMenu(children:[UIAction(title: "circleoflife", handler: addElement),UIAction(title: "woman", handler: addElement),UIAction(title: "house", handler: addElement),UIAction(title: "mountain", handler: addElement), UIAction(title: "hut", handler: addElement),UIAction(title: "tree", handler: addElement),UIAction(title: "pond", handler: addElement)])
        
    }
    
    
    
    //raycast
    
    @objc func raycastForPlane(recognizer:UITapGestureRecognizer) {
        print("in the raycast method")
        let location=recognizer.location(in: arView)
        let raycastResults=arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
        
        
        guard let detectedPlane=raycastResults.first else
        {
        print("no plane found")
        return
        }
        
        print("plane found\(detectedPlane.description)& adding model")
        guard let name=modelToBeAdded else{
            print("failed to add model")
            return
        }
        let anchor=ARAnchor(name: name, transform: detectedPlane.worldTransform)
        arView.session.add(anchor: anchor)
        self.placeObject(named: name, forAnchor: anchor)
        
        
        
        
    }
    //it is assumed that the entity name is same as AnchorName
    func placeObject(named entityName: String, forAnchor anchor: ARAnchor) {
        let entity = try! ModelEntity.loadModel(named: entityName)
        entity.generateCollisionShapes(recursive: true)
        arView.installGestures([.translation], for: entity)
        let anchorEntity=AnchorEntity(anchor: anchor)
        anchorEntity.addChild(entity)
        print("the position of the entity is ", entity.position)
        
        arView.scene.addAnchor(anchorEntity)
        print("entity added")
    }
    
    func setupArCoachingOverlay(on arView:ARView) {
        self.arCoachingOverlay = ARCoachingOverlayView()
        arCoachingOverlay.goal = .horizontalPlane
        arCoachingOverlay.session = arView.session
        arView.addSubview(arCoachingOverlay)
        arCoachingOverlay.frame = arView.frame
    }
    
}

extension ViewController:ARSessionDelegate{
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        print(anchors)
        for anchor in anchors{
            guard let anchorName=anchor.name, anchorName=="test" else {
                print("anchor not found")
                return
            }
            print("anchor found")
            placeObject(named: anchorName, forAnchor: anchor)
            
            self.modelToBeAdded=nil
        }
    }
}
