import JSON

public enum RichMessageListenerType: String {
    case Touch = "touch" // Fixed Value
}

public enum RichMessageActionType: String {
    case Web = "web" // Fixed Value
}

public struct Bounds {
    let x: Int
    let y: Int
    let width: Int
    let height: Int
    
    public init(x: Int = 0, y: Int = 0, width: Int = 1040, height: Int = 1040) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }

    private var array: [Int] {
        return [x, y, width, height]
    }
    
    public var json: JSON {
        return JSON.array(array.map(JSON.infer))
    }
}

public struct RichMessageAction {
    let type: RichMessageActionType
    let text: String
    let name: String
    let linkUri: String
    
    public init(type: RichMessageActionType = .Web, name: String, text: String, linkUri: String) {
        self.type = type
        self.name = name
        self.text = text
        self.linkUri = linkUri
    }
    
    public var json: JSON {
        return JSON.infer([
            "type": JSON.infer(type.rawValue),
            "text": JSON.infer(text),
            "params": JSON.infer([ "linkUri": JSON.infer(linkUri) ])
        ])
    }
}

public struct RichMessageListener {
    let type: RichMessageListenerType
    let bounds: Bounds
    let action: RichMessageAction
    
    public init(type: RichMessageListenerType = .Touch, bounds: Bounds, action: RichMessageAction) {
        self.type = type
        self.bounds = bounds
        self.action = action
    }
    
    public var json: JSON {
        return JSON.infer([
            "type": JSON.infer(type.rawValue),
            "params": bounds.json,
            "action": JSON.infer(action.name)
        ])
    }
}

public class RichMessageBuilder: Builder {
    private let height: Int
    private var listeners = [RichMessageListener]()
    private var actions = [RichMessageAction]()
    
    public init(height: Int = 1040) throws {
        guard height < 2080 else {
            throw BuilderError.InvalidHeight
        }
        self.height = height
    }

    private var jsonListeners: JSON {
        return JSON.infer(listeners.map { $0.json })
    }
    private var jsonActions: JSON {
        var dic = [String:JSON]()
        actions.forEach { dic[$0.name] = $0.json }
        return JSON.infer(dic)
    }

    public func addListener(listener: RichMessageListener) {
        listeners.append(listener)
        actions.append(listener.action)
    }
    
    public func build() throws -> JSON? {
        guard listeners.count > 0 && actions.count > 0 else {
            throw BuilderError.BuildFailed
        }
        
        // construct canvas
        var canvas = JSON.infer([:])
        canvas["width"] = JSON.infer(1040)  // Fixed 1040
        canvas["height"] = JSON.infer(height)  // Max value is 2080
        canvas["initialScene"] = JSON.infer("scene1")
        
        // construct images
        var image1 = JSON.infer([:])
        image1["x"] = JSON.infer(0) // Fixed 0
        image1["y"] = JSON.infer(0) // Fixed 0
        image1["w"] = JSON.infer(1040) // Fixed 1040
        image1["h"] = JSON.infer(height) // Max value is 2080
        let images = JSON.infer([
            "image1": image1
        ])

        // construct draws
        var draw = JSON.infer([:])
        draw["image"] = JSON.infer("image1")
        draw["x"] = JSON.infer(0) // Fixed 0
        draw["y"] = JSON.infer(0) // Fixed 0
        draw["w"] = JSON.infer(1040) // Any one of 1040, 700, 460, 300, 240. This value must be same as the image width.
        draw["h"] = JSON.infer(height) // Max value is 2080
        let draws = JSON.infer([ draw ])

        // construct scenes
        let scenes = JSON.infer([
            "scene1": JSON.infer([
                "draws": draws,
                "listeners": jsonListeners,
            ])
        ])

        // return rich message
        return JSON.infer([
            "canvas": canvas,
            "images": images,
            "actions": jsonActions,
            "scenes": scenes,
        ])
    }
}
