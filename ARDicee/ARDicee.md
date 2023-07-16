# MyFirst ARkit

## 전체코드

```swift
//
//  ViewController.swift
//  ARDicee
//
//  Created by 김정원 on 2023/07/08.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    var diceArray = [SCNNode]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    // MARK : Dice Rendering method
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResult = results.first {
                addDice(atLocation: hitResult)
            }
        }
    }
    
    func addDice(atLocation location: ARHitTestResult)
    {
        //Create a new scene
        let diceScene = SCNScene(named: "/diceCollada.scn")!
        
        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true){
            
            diceNode.position = SCNVector3(
                x: location.worldTransform.columns.3.x,
                y: location.worldTransform.columns.3.y,
                z: location.worldTransform.columns.3.z)
            
            diceArray.append(diceNode)
            
            sceneView.scene.rootNode.addChildNode(diceNode)
            roll(dice: diceNode)
        }
    }
    func roll(dice:SCNNode){
        let randomX = Float(arc4random_uniform(4) + 1 ) * (Float.pi/2)
        let randomZ = Float(arc4random_uniform(4) + 1 ) * (Float.pi/2)
        dice.runAction(SCNAction.rotateBy(x: CGFloat(randomX * 5), y: 0, z: CGFloat(randomZ * 5), duration: 0.5))
    }
    func rollAll() {
        if !diceArray.isEmpty {
            for dice in diceArray {
                roll(dice: dice)
            }
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    @IBAction func removeAllDice(_ sender: Any) {
        if diceArray.isEmpty {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
        }
        
    }
    @IBAction func rollAgain(_ sender: Any) {
        rollAll()
        
    }
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
    //MARK : ARSCNViewDelegateMethod
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        
        let planeNode = createPlane(withPlaneAnchor: planeAnchor)
                
        node.addChildNode(planeNode)
        
        // MARK : Plane Rendering  Methods
    }
    func createPlane(withPlaneAnchor planeAnchor: ARPlaneAnchor) -> SCNNode {
    
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        
        let planeNode = SCNNode()
        
        planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
        
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        
        let gridMaterial = SCNMaterial()
        
        gridMaterial.diffuse.contents = UIImage(named: "artisan.scnassets/New_BlueBase_Color.png")
        
        plane.materials = [gridMaterial]
        
        planeNode.geometry = plane
        
        return planeNode
    }
}

```

## ARSCNView 설정과 초기화

```swift
override func viewDidLoad() {
        super.viewDidLoad()

				// 특징점을 디버깅 모드에서 표시한다. 디버깅 모드에서는 AR 환경에서 인식된 특징점이 화면에 표시하기 위함 
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]

				
        sceneView.delegate = self
				// sceneView 에 기본 조명을 자동으로 활성화 환다. 이는 3D 객체 조명의 그림자를 자동으로 조정해 더 현실적 효과를 제공
        sceneView.autoenablesDefaultLighting = true
        
        
    }
```

## view가 화면에 나타나기 직전 수행 메서드

```swift
override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // ARkit 에서 제공하는 세션 구성 객체로 AR 환경을 추적하고 가상 객체를 렌더링 하는데 필요
        let configuration = ARWorldTrackingConfiguration()
        // 수평 평면을 감지하는 기능을 활성화 
        configuration.planeDetection = .horizontal
        
        // session 을 생성한 구성으로 실행한다. 
        sceneView.session.run(configuration)
    }
```

## Dice 가 랜더링 될때

```swift
// 사용자의 터치 이벤트가 시작될 때 호출  
override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            // 터치 위치를 가져옴 
            let touchLocation = touch.location(in: sceneView)
            // 터치 위치에서 가상 평면을 감지
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            // 처음 감지된 곳이라면 주사위를 더해준다. 
            if let hitResult = results.first {
                addDice(atLocation: hitResult)
            }
        }
    }
```

## 주사위 추가 메서드

```swift
// dice 의 위치를 ARHitTestResult 에서 얻은 행렬의 컬럼 값으로 설정 
func addDice(atLocation location: ARHitTestResult)
    {
        // 새로운 객체인 diceScene 생성 
        let diceScene = SCNScene(named: "/diceCollada.scn")!
        
				// 조건문은 childNode(withName:recursively:) 메서드의 결과가 옵셔널 값인지 확인하고, 값이 존재한다면 diceNode라는 상수에 할당하려고 시도.
        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true){
            // 주사위의 포지션 정해줌 
            diceNode.position = SCNVector3(
                x: location.worldTransform.columns.3.x,
                y: location.worldTransform.columns.3.y,
                z: location.worldTransform.columns.3.z)
            // 배열에 diceNode 추가 모든 주사위 위치를 추적하기 위해 사용 
            diceArray.append(diceNode)
            //diceNode 를 sceneView 루트노드에 추가해 시각적으로 표시한다. 
            sceneView.scene.rootNode.addChildNode(diceNode)
						// 주사위 굴리는 애니매이션 호출 
            roll(dice: diceNode)
        }
    }
```

## 주사위 굴리기

```swift
func roll(dice:SCNNode){

				// 1~4 사이의 난수를 설정해 주사위의 회전각도를 정함 
        let randomX = Float(arc4random_uniform(4) + 1 ) * (Float.pi/2)
        let randomZ = Float(arc4random_uniform(4) + 1 ) * (Float.pi/2)
				// 주사위를 회전시키는 액션 
        dice.runAction(SCNAction.rotateBy(x: CGFloat(randomX * 5), y: 0, z: CGFloat(randomZ * 5), duration: 0.5))
    }
// 전부 굴리는 역할 
func rollAll() {
        if !diceArray.isEmpty {
            for dice in diceArray {
                roll(dice: dice)
            }
            
        }
    }
```

## 화면에서 사라기전에 호출되는 메서드

```swift
override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
```

## 버튼과 연결되어 주사위를 없애고, 다시 굴리는 버튼

```swift
@IBAction func removeAllDice(_ sender: Any) {
        if diceArray.isEmpty {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
        }
        
    }
    @IBAction func rollAgain(_ sender: Any) {
        rollAll()
        
    }
// 모션이 끝났을때 
override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
```

## 새로운 앵커가 감지되었을때 호출

```swift
//ARPlaneAnchor 로 캐스팅된 앵커를 확인하고 , 해당 앵커에 평면을 생성한다. 
func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        // 평면노드를 생성한다. 
        let planeNode = createPlane(withPlaneAnchor: planeAnchor)
        // 생성된 평면 노드를 부모노드에 추가한다. 
        node.addChildNode(planeNode)
        
        // MARK : Plane Rendering  Methods
    }
```

## 평면노드를 생성하는 역할

```swift
func createPlane(withPlaneAnchor planeAnchor: ARPlaneAnchor) -> SCNNode {
		    // 평면의 너비와 높이를 가져와 SCNPlane 객체를 생성한다. extent : 평면의 크기를 나타냄 
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        // SCNNode 를생성해 평면의 노드로 사용한다. 
        let planeNode = SCNNode()
        // 평면노드의 위치 설정 
        planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
        // SCNMatrix4MakeRotation 을 사용해 planeNode의 변환 행렬을 설정해 x축 주위로 pi/2만큼 회전해 평면이 수형으로 표시  
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        
        let gridMaterial = SCNMaterial()
        //SCNMaterial 객체를 생성하고, 그리드 머티리얼에 사용할 텍스처를 설정
        gridMaterial.diffuse.contents = UIImage(named: "artisan.scnassets/New_BlueBase_Color.png")
        //plane의 materials 배열에 그리드 머티리얼을 할당
        plane.materials = [gridMaterial]
        //planeNode의 geometry를 plane으로 설정하여 평면의 기하 모양을 정의
        planeNode.geometry = plane
        
        return planeNode
    }
```