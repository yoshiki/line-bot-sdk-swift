import JSON

public class MessageBuilder: Builder {
    private var messages = [JSON]()
    
    public func build() throws -> JSON? {
        guard messages.count > 0 else {
            throw BuilderError.contentsNotFound
        }
        return JSON.infer(messages)
    }

    public func addText(text: String) {
        messages.append(JSON.infer([
            "type": MessageType.text.asJSON,
            "text": text.asJSON
        ]))
    }
    
    public func addImage(imageUrl: String, previewUrl: String) {
        messages.append(JSON.infer([
            "type": MessageType.image.asJSON,
            "originalContentUrl": imageUrl.asJSON,
            "previewImageUrl": previewUrl.asJSON,
        ]))
    }

    public func addVideo(videoUrl: String, previewUrl: String) {
        messages.append(JSON.infer([
            "type": MessageType.video.asJSON,
            "originalContentUrl": videoUrl.asJSON,
            "previewImageUrl": previewUrl.asJSON,
        ]))
    }

    public func addAudio(audioUrl: String, duration: Int) {
        messages.append(JSON.infer([
            "type": MessageType.audio.asJSON,
            "originalContentUrl": audioUrl.asJSON,
            "duration": duration.asJSON
        ]))
    }

    public func addLocation(title: String, address: String, latitude: String, longitude: String) {
        messages.append(JSON.infer([
            "type": MessageType.location.asJSON,
            "title": title.asJSON,
            "address": address.asJSON,
            "latitude": latitude.asJSON,
            "longitude": longitude.asJSON,
        ]))
    }

    public func addSticker(stickerId: String, packageId: String) {
        messages.append(JSON.infer([
            "type": MessageType.sticker.asJSON,
            "packageId": packageId.asJSON,
            "stickerId": stickerId.asJSON
        ]))
    }
    
    public func addImagemap(baseUrl: String,
                            altText: String,
                            width: ImagemapBaseSize = .length1040,
                            height: ImagemapBaseSize = .length1040,
                            actionBuilder: ImagemapActionBuilder) {
        let builder = ImagemapMessageBuilder(baseUrl: baseUrl, altText: altText, width: width, height: height, actionBuilder: actionBuilder)
        if let message = builder.build() {
            messages.append(message)
        }
    }
}
