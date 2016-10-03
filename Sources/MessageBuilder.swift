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
        let content = JSON.infer([
            "contentType": JSON.infer(ContentType.Text.rawValue),
            "text": JSON.infer(text),
        ])
        contents.append(content)
    }
    
    public func addImage(imageUrl: String, previewUrl: String) {
        let content = JSON.infer([
            "contentType": JSON.infer(ContentType.Image.rawValue),
            "originalContentUrl": JSON.infer(imageUrl),
            "previewImageUrl": JSON.infer(previewUrl),
        ])
        contents.append(content)
    }

    public func addVideo(videoUrl: String, previewUrl: String) {
        let content = JSON.infer([
            "contentType": JSON.infer(ContentType.Video.rawValue),
            "originalContentUrl": JSON.infer(videoUrl),
            "previewImageUrl": JSON.infer(previewUrl),
        ])
        contents.append(content)
    }

    public func addAudio(audioUrl: String, duration: Int) {
        let metaData = JSON.infer([ "AUDLEN": "\(duration)" ])
        let content = JSON.infer([
            "contentType": JSON.infer(ContentType.Audio.rawValue),
            "originalContentUrl": JSON.infer(audioUrl),
            "contentMetadata": metaData,
        ])
        contents.append(content)
    }

    public func addLocation(text: String, address: String, latitude: String, longitude: String) {
        let location = JSON.infer([
            "title": JSON.infer(address),
            "latitude": JSON.infer(latitude),
            "longitude": JSON.infer(longitude),
        ])
        let content = JSON.infer([
            "contentType": JSON.infer(ContentType.Location.rawValue),
            "text": JSON.infer(text),
            "location": location,
        ])
        contents.append(content)
    }

    public func addSticker(stkId: String, stkPkgId: String, stkVer: String) {
        let metaData = JSON.infer([
            "STKID": JSON.infer(stkId),
            "STKPKGID": JSON.infer(stkPkgId),
            "STKVER": JSON.infer(stkVer),
        ])
        let content = JSON.infer([
            "contentType": JSON.infer(ContentType.Sticker.rawValue),
            "contentMetadata": metaData,
        ])
        contents.append(content)
    }
}
