import JSON

public class MessageBuilder: Builder {
    private var messages = [JSON]()
    
    public func build() throws -> JSON? {
        guard messages.count > 0 else {
            throw BuilderError.ContentsNotFound
        }
        return JSON.infer(messages)
    }

    public func addText(text: String) {
        messages.append(JSON.infer([
            "type": Type.Text.asJSON,
            "text": text.asJSON
        ]))
    }
    
    public func addImage(imageUrl: String, previewUrl: String) {
        messages.append(JSON.infer([
            "type": Type.Image.asJSON,
            "originalContentUrl": imageUrl.asJSON,
            "previewImageUrl": previewUrl.asJSON,
        ]))
    }

    public func addVideo(videoUrl: String, previewUrl: String) {
        messages.append(JSON.infer([
            "type": Type.Video.asJSON,
            "originalContentUrl": videoUrl.asJSON,
            "previewImageUrl": previewUrl.asJSON,
        ]))
    }

    public func addAudio(audioUrl: String, duration: Int) {
        messages.append(JSON.infer([
            "type": Type.Audio.asJSON,
            "originalContentUrl": audioUrl.asJSON,
            "duration": duration.asJSON
        ]))
    }

    public func addLocation(title: String, address: String, latitude: String, longitude: String) {
        messages.append(JSON.infer([
            "type": Type.Location.asJSON,
            "title": title.asJSON,
            "address": address.asJSON,
            "latitude": latitude.asJSON,
            "longitude": longitude.asJSON,
        ]))
    }

    public func addSticker(stickerId: String, packageId: String) {
        messages.append(JSON.infer([
            "type": Type.Sticker.asJSON,
            "packageId": packageId.asJSON,
            "stickerId": stickerId.asJSON
        ]))
    }
}
