import JSON

public enum TemplateType: String {
    case buttons  = "buttons"
    case confirm  = "confirm"
    case carousel = "carousel"

    public var asJSON: JSON {
        return JSON.infer(rawValue)
    }
}

public enum TemplateActionType: String {
    case postback = "postback"
    case message  = "message"
    case uri      = "uri"
    
    public var asJSON: JSON {
        return JSON.infer(rawValue)
    }
}

public protocol TemplateAction {
    var type: TemplateActionType { get }
    var asJSON: JSON { get }
}

public struct PostbackTemplateAction: TemplateAction {
    public let type: TemplateActionType = .postback
    private let label: String
    private let data: String
    private let text: String?
    
    public init(label: String, data: String, text: String? = nil) {
        self.label = label
        self.data = data
        self.text = text
    }
    
    public var asJSON: JSON {
        var action = [
            "type": type.asJSON,
            "label": label.asJSON,
            "data": data.asJSON
        ]
        if let text = text {
            action["text"] = text.asJSON
        }
        return JSON.infer(action)
    }
}

public struct MessageTemplateAction: TemplateAction {
    public let type: TemplateActionType = .message
    private let label: String
    private let text: String
    
    public init(label: String, text: String) {
        self.label = label
        self.text = text
    }
    
    public var asJSON: JSON {
        return JSON.infer([
            "type": type.asJSON,
            "label": label.asJSON,
            "text": text.asJSON
        ])
    }
}

public struct UriTemplateAction: TemplateAction {
    public let type: TemplateActionType = .uri
    private let label: String
    private let data: String
    private let uri: String
    
    public init(label: String, data: String, uri: String) {
        self.label = label
        self.data = data
        self.uri = uri
    }
    
    public var asJSON: JSON {
        return JSON.infer([
            "type": type.asJSON,
            "label": label.asJSON,
            "uri": uri.asJSON
        ])
    }
}

public protocol Template {
    var type: TemplateType { get }
    var asJSON: JSON { get }
}

public struct ButtonsTemplate: Template {
    public let type: TemplateType = .buttons
    private let thumbnailImageUrl: String?
    private let title: String?
    private let text: String
    public var actions: [TemplateAction]
    
    init(thumbnailImageUrl: String? = nil, title: String? = nil, text: String) {
        self.thumbnailImageUrl = thumbnailImageUrl
        self.title = title
        self.text = text
        self.actions = [TemplateAction]()
    }
    
    public mutating func addAction(action: TemplateAction) {
        actions.append(action)
    }
    
    public var asJSON: JSON {
        var tmpl = [
            "type": type.asJSON,
            "text": text.asJSON
        ]
        if let thumbnailImageUrl = thumbnailImageUrl {
            tmpl["thumbnailImageUrl"] = thumbnailImageUrl.asJSON
        }
        if let title = title {
            tmpl["title"] = title.asJSON
        }
        if !actions.isEmpty {
            tmpl["actions"] = JSON.infer(actions.flatMap { $0.asJSON })
        }
        return JSON.infer(tmpl)
    }
}

public struct ConfirmTemplate: Template {
    public var type: TemplateType = .confirm
    private let text: String
    public var actions: [TemplateAction]
    
    init(text: String) {
        self.text = text
        self.actions = [TemplateAction]()
    }
    
    public mutating func addAction(action: TemplateAction) {
        actions.append(action)
    }
    
    public var asJSON: JSON {
        var tmpl = [
            "type": type.asJSON,
            "text": text.asJSON
        ]
        if !actions.isEmpty {
            tmpl["actions"] = JSON.infer(actions.flatMap { $0.asJSON })
        }
        return JSON.infer(tmpl)
    }
}

public struct CarouselTemplate: Template {
    public var type: TemplateType = .carousel
    public var columns: [CarouselColumn]
    
    init() {
        self.columns = [CarouselColumn]()
    }
    
    public mutating func addColumn(column: CarouselColumn) {
        columns.append(column)
    }
    
    public var asJSON: JSON {
        var tmpl = [
            "type": type.asJSON,
        ]
        if !columns.isEmpty {
            tmpl["columns"] = JSON.infer(columns.flatMap { $0.asJSON })
        }
        return JSON.infer(tmpl)
    }
}

public struct CarouselColumn {
    private let thumbnailImageUrl: String?
    private let title: String?
    private let text: String
    public var actions: [TemplateAction]
    
    init(thumbnailImageUrl: String? = nil, title: String? = nil, text: String) {
        self.thumbnailImageUrl = thumbnailImageUrl
        self.title = title
        self.text = text
        self.actions = [TemplateAction]()
    }
    
    public var asJSON: JSON {
        var tmpl = [
            "text": text.asJSON
        ]
        if let thumbnailImageUrl = thumbnailImageUrl {
            tmpl["thumbnailImageUrl"] = thumbnailImageUrl.asJSON
        }
        if let title = title {
            tmpl["title"] = title.asJSON
        }
        if !actions.isEmpty {
            tmpl["actions"] = JSON.infer(actions.flatMap { $0.asJSON })
        }
        return JSON.infer(tmpl)
    }
}

public class TemplateMessageBuilder: Builder {
    private let altText: String
    private let template: Template
    
    public init(altText: String, template: Template) {
        self.altText = altText
        self.template = template
    }
    
    public func build() throws -> JSON? {
        return JSON.infer([
            "type": MessageType.template.asJSON,
            "altText": altText.asJSON,
            "template": template.asJSON
        ])
    }
}
