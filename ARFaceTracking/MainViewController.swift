//
//  MainViewController.swift
//  ARFaceTracking
//
//  Created by wuufone on 2019/7/24.
//  Copyright © 2019 江武峯. All rights reserved.
//

import UIKit
import ARKit

class MainViewController: UIViewController {
    @IBOutlet weak var arScnView: ARSCNView!
    @IBOutlet weak var infoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.infoLabel.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if ARFaceTrackingConfiguration.isSupported {
            self.arScnView.session.run(ARFaceTrackingConfiguration())
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if ARFaceTrackingConfiguration.isSupported {
            self.arScnView.session.pause()
        }
    }
}

extension MainViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARFaceAnchor {
            node.geometry = ARSCNFaceGeometry(device: self.arScnView.device!)
        }
    }
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARFaceAnchor {
            let faceAnchor = anchor as! ARFaceAnchor
            let faceGeometry = node.geometry as! ARSCNFaceGeometry
            let faceMaterial = faceGeometry.materials.first
            faceMaterial?.fillMode = .fill
            faceMaterial?.diffuse.contents = UIImage(named: "mask")
            faceGeometry.update(from: faceAnchor.geometry)

            if self.didBlinkLeftEye(faceAnchor) {
                DispatchQueue.main.async {
                    self.infoLabel.isHidden = false
                    self.infoLabel.text = "貶左眼"
                }
            } else {
                DispatchQueue.main.async {
                    self.infoLabel.isHidden = true
                    self.infoLabel.text = ""
                }
            }
        }
    }
}

extension MainViewController {
    private func didBlinkLeftEye(_ faceAnchor: ARFaceAnchor) -> Bool {
        let value = lround(Double(truncating: faceAnchor.blendShapes[.eyeBlinkLeft]!))
        if value == 1 {
            return true
        }
        return false
    }
}
