import JSON

public typealias TemplateBuilder = () -> Template

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

public protocol TemplateActionMutable {
    var actions: [TemplateAction] { get }
    func addAction(action: TemplateAction)
}

public protocol TemplateColumnMutable {
    var columns: [CarouselColumn] { get }
    func addColumn(column: CarouselColumn)
}

public protocol Template {
    var type: TemplateType { get }
    var asJSON: JSON { get }
}

public class ButtonsTemplate: Template, TemplateActionMutable {
    public let type: TemplateType = .buttons
    private let thumbnailImageUrl: String?
    private let title: String?
    private let text: String
    public var actions = [TemplateAction]()
    
    public init(thumbnailImageUrl: String? = nil, title: String? = nil, text: String) {
        self.thumbnailImageUrl = thumbnailImageUrl
        self.title = title
        self.text = text
    }
    
    public func addAction(action: TemplateAction) {
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

public class ConfirmTemplate: Template, TemplateActionMutable {
    public var type: TemplateType = .confirm
    private let text: String
    public var actions = [TemplateAction]()
    
    public init(text: String) {
        self.text = text
    }
    
    public func addAction(action: TemplateAction) {
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

public class CarouselTemplate: Template, TemplateColumnMutable {
    public var type: TemplateType = .carousel
    public var columns = [CarouselColumn]()
    
    public init() {}

    public func addColumn(column: CarouselColumn) {
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

public class CarouselColumn: TemplateActionMutable {
    private let thumbnailImageUrl: String?
    private let title: String?
    private let text: String
    public var actions = [TemplateAction]()
    
    public init(thumbnailImageUrl: String? = nil, title: String? = nil, text: String) {
        self.thumbnailImageUrl = thumbnailImageUrl
        self.title = title
        self.text = text
    }

    public func addAction(action: TemplateAction) {
        actions.append(action)
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

public enum TemplateError: Error {
    case tooManyActions, tooManyColumns, actionsNotFound, columnsNotFound
}

public struct TemplateMessageBuilder: Builder {
    private let altText: String
    private let template: Template
    
    public init(altText: String, template: Template) {
        self.altText = altText
        self.template = template
    }
    
    public func build() throws -> JSON? {
        try validate()
        return JSON.infer([
            "type": MessageType.template.asJSON,
            "altText": altText.asJSON,
            "template": template.asJSON
        ])
    }
    
    private func validate() throws {
        if case .buttons = template.type, let t = template as? ButtonsTemplate {
            if t.actions.isEmpty {
                throw TemplateError.actionsNotFound
            } else if t.actions.count > 4 {
                throw TemplateError.tooManyActions
            }
        } else if case .confirm = template.type, let t = template as? ConfirmTemplate {
            if t.actions.isEmpty {
                throw TemplateError.actionsNotFound
            } else if t.actions.count > 2 {
                throw TemplateError.tooManyActions
            }
        } else if case .carousel = template.type, let t = template as? CarouselTemplate {
            if t.columns.isEmpty {
                throw TemplateError.columnsNotFound
            } else if t.columns.count > 5 {
                throw TemplateError.tooManyColumns
            }
            for column in t.columns {
                if column.actions.isEmpty {
                    throw TemplateError.actionsNotFound
                } else if column.actions.count > 4 {
                    throw TemplateError.tooManyActions
                }
            }
        }
    }
}
