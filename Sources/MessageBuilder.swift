import JSON

public typealias MessageBuilderType = MessageBuilder -> Void

public class MessageBuilder {
    public var contents: [JSON]
    public var content: JSON? {
        return contents[0]
    }
    
    public init(contents: [JSON] = []) {
        self.contents = contents
    }

    public func addText(text: String) {
        let content = JSON.from([
            "contentType": JSON.from(ContentType.Text.rawValue),
            "text": JSON.from(text),
        ])
        contents.append(content)
    }
    
    public func addImage(imageUrl: String, previewUrl: String) {
        let content = JSON.from([
            "contentType": JSON.from(ContentType.Image.rawValue),
            "originalContentUrl": JSON.from(imageUrl),
            "previewImageUrl": JSON.from(previewUrl),
        ])
        contents.append(content)
    }

    public func addVideo(videoUrl: String, previewUrl: String) {
        let content = JSON.from([
            "contentType": JSON.from(ContentType.Video.rawValue),
            "originalContentUrl": JSON.from(videoUrl),
            "previewImageUrl": JSON.from(previewUrl),
        ])
        contents.append(content)
    }

    public func addAudio(audioUrl: String, duration: Int) {
        let metaData = JSON.from([ "AUDLEN": "\(duration)" ])
        let content = JSON.from([
            "contentType": JSON.from(ContentType.Audio.rawValue),
            "originalContentUrl": JSON.from(audioUrl),
            "contentMetadata": metaData,
        ])
        contents.append(content)
    }

    public func addLocation(text: String, address: String, latitude: String, longitude: String) {
        let location = JSON.from([
            "title": JSON.from(address),
            "latitude": JSON.from(latitude),
            "longitude": JSON.from(longitude),
        ])
        let content = JSON.from([
            "contentType": JSON.from(ContentType.Location.rawValue),
            "text": JSON.from(text),
            "location": location,
        ])
        contents.append(content)
    }

    public func addSticker(stkId: String, stkPkgId: String, stkVer: String) {
        let metaData = JSON.from([
            "STKID": JSON.from(stkId),
            "STKPKGID": JSON.from(stkPkgId),
            "STKVER": JSON.from(stkVer),
        ])
        let content = JSON.from([
            "contentType": JSON.from(ContentType.Sticker.rawValue),
            "contentMetadata": metaData,
        ])
        contents.append(content)
    }
}
