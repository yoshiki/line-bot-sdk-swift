import JSON
import URI

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
        return JSON.from(array.map(JSON.from))
    }
}

public struct RichMessageAction {
    let type: RichMessageActionType
    let text: String
    let name: String
    let linkUri: String
    
    public init(type: RichMessageActionType = .Web, text: String, name: String, linkUri: String) {
        self.type = type
        self.text = text
        self.name = name
        self.linkUri = linkUri
    }
    
    public var json: JSON {
        return JSON.from([
            name: JSON.from([
                "type": JSON.from(type.rawValue),
                "text": JSON.from(text),
                "params": JSON.from([ "linkUri": JSON.from(linkUri) ])
            ])
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
        return JSON.from([
            "type": JSON.from(type.rawValue),
            "params": bounds.json,
            "action": JSON.from(action.name)
        ])
    }
}

public class RichMessageBuilder: Builder {
    public var contents: [JSON]

    private var listeners = [RichMessageListener]()
    private var actions = [RichMessageAction]()

    public required init(contents: [JSON] = []) {
        self.contents = contents
    }
    
    public func addListener(listener: RichMessageListener) {
        listeners.append(listener)
        actions.append(listener.action)
    }
    
    public var json: JSON {
        let canvas = JSON.from([
            "width": JSON.from(1040), // Fixed 1040
            "height": JSON.from(1040), // Max value is 2080
            "initialScene": JSON.from("scene1"),
        ])
        let images = JSON.from([
            "image1": JSON.from([
                "x": JSON.from(0), // Fixed 0
                "y": JSON.from(0), // Fixed 0
                "w": JSON.from(1040), // Fixed 1040
                "h": JSON.from(1040), // Max value is 2080
            ])
        ])
        let draw = JSON.from([
            "image": JSON.from("image1"),
            "x": JSON.from(0), // Fixed 0
            "y": JSON.from(0), // Fixed 0
            "w": JSON.from(1040), // Fixed 1040
            "h": JSON.from(1040), // Max value is 2080
        ])
        let draws = JSON.from([ draw ])
        let scenes = JSON.from([
            "scene1": JSON.from([
                "draws": draws,
                "listeners": JSON.from(1)
            ])
        ])
        return JSON.from([
            "canvas": canvas,
            "images": images,
            "actions": JSON.from(1),
            "scenes": scenes,
        ])
    }
}