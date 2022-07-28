//
//  ARGameRepresentableView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 27.07.2022.
//

import SwiftUI
import ARKit
import Combine

enum LinkAction {
    case resetModel
}

class VCLink : ObservableObject {
    @Published var action : LinkAction?
    
    func resetModel() {
        action = .resetModel
    }
}

struct ARGameRepresentableView: UIViewControllerRepresentable {
    typealias UIViewControllerType = ARGameUIKitView
    
    var vcLink : VCLink
    
    func makeUIViewController(context: Context) -> ARGameUIKitView {
        let vc = ARGameUIKitView()
        return vc
    }
    
    func updateUIViewController(_ uiViewController:
                                ARGameRepresentableView.UIViewControllerType, context:
                                UIViewControllerRepresentableContext<ARGameRepresentableView>) {
        context.coordinator.viewController = uiViewController
        context.coordinator.vcLink = vcLink
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    
    class Coordinator {
        var vcLink : VCLink? {
            didSet {
                cancelable = vcLink?.$action.sink(receiveValue: { (action) in
                    guard let action = action else {
                        return
                    }
                    self.viewController?.action(action)
                })
            }
        }
        
        var viewController : ARGameUIKitView?
        private var cancelable : AnyCancellable?
    }
}


class ARGameUIKitView: UIViewController {
    
    var sceneView: ARSCNView {
        return self.view as! ARSCNView
    }
    
    override func loadView() {
        self.view = ARSCNView(frame: .zero)
    }
    
    let manager = ARGameManger.shared
    
    let fadeDuration: TimeInterval = 0.3
    let rotateDuration: TimeInterval = 3
    let waitDuration: TimeInterval = 10
    
    func action(_ action : LinkAction) {
        switch action {
        case .resetModel:
            resetTrackingConfiguration()
        }
    }
    
    lazy var fadeAndSpinAction: SCNAction = {
        self.manager.objectFounded = true
        
        return .sequence([
            .fadeIn(duration: fadeDuration),
            .rotateBy(x: 0, y: 0, z: CGFloat.pi * 360 / 180, duration: rotateDuration),
//            .wait(duration: waitDuration),
//            .fadeOut(duration: fadeDuration)
        ])
    }()
    
    lazy var fadeAction: SCNAction = {
        return .sequence([
            .fadeOpacity(by: 0.8, duration: fadeDuration),
            .wait(duration: waitDuration),
            .fadeOut(duration: fadeDuration)
        ])
    }()
    
    lazy var treeNode: SCNNode = {
        guard let scene = SCNScene(named: "tree.scn"),
              let node = scene.rootNode.childNode(withName: "tree", recursively: false) else { return SCNNode() }
        let scaleFactor = 0.005
        node.scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
        node.eulerAngles.x = -.pi / 2
        return node
    }()
    
    lazy var bookNode: SCNNode = {
        guard let scene = SCNScene(named: "book.scn"),
              let node = scene.rootNode.childNode(withName: "book", recursively: false) else { return SCNNode() }
        let scaleFactor  = 0.1
        node.scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
        return node
    }()
    
    lazy var mountainNode: SCNNode = {
        guard let scene = SCNScene(named: "mountain.scn"),
              let node = scene.rootNode.childNode(withName: "mountain", recursively: false) else { return SCNNode() }
        let scaleFactor  = 0.25
        node.scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
        node.eulerAngles.x += -.pi / 2
        return node
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.scene = SCNScene()
        configureLighting()
    }
    
    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        resetTrackingConfiguration()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func resetTrackingConfiguration() {
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else { return }
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = referenceImages
        let options: ARSession.RunOptions = [.resetTracking, .removeExistingAnchors]
        sceneView.session.run(configuration, options: options)
    }
}

extension ARGameUIKitView: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            guard let imageAnchor = anchor as? ARImageAnchor,
                  let imageName = imageAnchor.referenceImage.name else {    
                return
            }
            
            // TODO: Comment out code
            //            let planeNode = self.getPlaneNode(withReferenceImage: imageAnchor.referenceImage)
            //            planeNode.opacity = 0.0
            //            planeNode.eulerAngles.x = -.pi / 2
            //            planeNode.runAction(self.fadeAction)
            //            node.addChildNode(planeNode)
            
            let overlayNode = self.getNode(withImageName: imageName)
            overlayNode.opacity = 0
            overlayNode.position.y = 0.2
            overlayNode.runAction(self.fadeAndSpinAction)
            node.addChildNode(overlayNode)
        }
    }
    
    func getPlaneNode(withReferenceImage image: ARReferenceImage) -> SCNNode {
        let plane = SCNPlane(width: image.physicalSize.width,
                             height: image.physicalSize.height)
        let node = SCNNode(geometry: plane)
        return node
    }
    
    func getNode(withImageName name: String) -> SCNNode {
        var node = SCNNode()
        switch name {
        case "Book":
            node = bookNode
        case "Snow Mountain":
            node = mountainNode
        case "Trees In the Dark":
            node = treeNode
        case "Mac":
            node = bookNode
        default:
            break
        }
        return node
    }
    
}
