import JSON

public class MessageBuilder: Builder {
    private var contents = [JSON]()
    
    public func build() throws -> JSON? {
        guard contents.count > 0 else {
            throw BuilderError.ContentsNotFound
        }
        return contents[0]
    }

    public func addText(text: String) {
        let content = JSON.from([
            "contentType": JSON.from(MessageContentType.Text.rawValue),
            "text": JSON.from(text),
        ])
        contents.append(content)
    }
    
    public func addImage(imageUrl: String, previewUrl: String) {
        let content = JSON.from([
            "contentType": JSON.from(MessageContentType.Image.rawValue),
            "originalContentUrl": JSON.from(imageUrl),
            "previewImageUrl": JSON.from(previewUrl),
        ])
        contents.append(content)
    }

    public func addVideo(videoUrl: String, previewUrl: String) {
        let content = JSON.from([
            "contentType": JSON.from(MessageContentType.Video.rawValue),
            "originalContentUrl": JSON.from(videoUrl),
            "previewImageUrl": JSON.from(previewUrl),
        ])
        contents.append(content)
    }

    public func addAudio(audioUrl: String, duration: Int) {
        let metaData = JSON.from([ "AUDLEN": "\(duration)" ])
        let content = JSON.from([
            "contentType": JSON.from(MessageContentType.Audio.rawValue),
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
            "contentType": JSON.from(MessageContentType.Location.rawValue),
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
            "contentType": JSON.from(MessageContentType.Sticker.rawValue),
            "contentMetadata": metaData,
        ])
        contents.append(content)
    }
}
