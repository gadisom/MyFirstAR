//
//  ViewController.swift
//  ARRuler
//
//  Created by 김정원 on 2023/07/17.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var dotNodes = [SCNNode]()
    var textNode = SCNNode()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // 3번째 점일때 점 배열을 제거한다.
        if dotNodes.count >= 2 {
            for dot in dotNodes {
                dot.removeFromParentNode()
            }
            dotNodes = [SCNNode]()
        }
        
        if let touchLocation = touches.first?.location(in: sceneView),
           let query = sceneView.raycastQuery(from: touchLocation, allowing: .estimatedPlane, alignment: .any)
        {
            let hitTestResult = sceneView.session.raycast(query)
            
            if let hitReuslt = hitTestResult.first {
                addDot(at:hitReuslt)
            }
        }
    }
    func addDot(at hitResult: ARRaycastResult) {
        let dotGeometry = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        dotGeometry.materials = [material]
        
        let dotNode = SCNNode(geometry: dotGeometry)
        dotNode.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
        
        sceneView.scene.rootNode.addChildNode(dotNode)
        dotNodes.append(dotNode)
        
        if dotNodes.count >= 2 {
            calculate()
        }
    }
    
    // 시작과 끝 거리를 측정
    func calculate (){
        let start = dotNodes[0]
        let end = dotNodes[1]
        print(start.position)
        print(end.position)
        
        // 피타고라스 정리로 3차원의 거리를 구한다.
        let a = end.position.x - start.position.x
        let b = end.position.y - start.position.y
        let c = end.position.z - start.position.z
        // pow 는 제곱
        let distance = sqrt(pow(a,2) + pow(b,2) + pow(c,2))
        // 마지막 점을 넘겨줌으로써 마지막 점 바로 위에 측정값이 나오게 한다.
        updateText(text : "\(abs(distance))", atPosition: end.position)
    }
    
    func updateText(text : String ,atPosition position: SCNVector3){
        
        // update 될때마다 앞에있는 text배열을 제거한다
        textNode.removeFromParentNode()
        
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        // 처음들어오는 색상을 red 로 설정한다.
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        // textNode 생성
        let textNode = SCNNode(geometry: textGeometry)
        // 텍스트 위치 설정
        textNode.position = SCNVector3(position.x,position.y + 0.01,position.z)
        
        // 현재 크기의 1% 로 만듬
        textNode.scale = SCNVector3(0.01,0.01,0.01)
        // sceneview 에 textnode 추가
        sceneView.scene.rootNode.addChildNode(textNode)
    }
}
