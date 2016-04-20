import JSON

public struct MessageBuilder {
    public func build(text text: String) -> JSON {
        return JSON.from([
            "contentType": JSON.from(ContentType.Text.rawValue),
            "text": JSON.from(text),
        ])
    }

    public func build(imageUrl imageUrl: String, previewUrl: String) -> JSON {
        return JSON.from([
            "contentType": JSON.from(ContentType.Image.rawValue),
            "originalContentUrl": JSON.from(imageUrl),
            "previewImageUrl": JSON.from(previewUrl),
        ])
    }

    public func build(videoUrl videoUrl: String, previewUrl: String) -> JSON {
        return JSON.from([
            "contentType": JSON.from(ContentType.Video.rawValue),
            "originalContentUrl": JSON.from(videoUrl),
            "previewImageUrl": JSON.from(previewUrl),
        ])
    }

    public func build(audioUrl audioUrl: String, duration: Int) -> JSON {
        let metaData = JSON.from([ "AUDLEN": "\(duration)" ])
        return JSON.from([
            "contentType": JSON.from(ContentType.Audio.rawValue),
            "originalContentUrl": JSON.from(audioUrl),
            "contentMetadata": metaData,
        ])
    }

    public func build(text text: String, address: String, latitude: String, longitude: String) -> JSON {
        let location = JSON.from([
            "title": JSON.from(address),
            "latitude": JSON.from(latitude),
            "longitude": JSON.from(longitude),
        ])
        return JSON.from([
            "contentType": JSON.from(ContentType.Location.rawValue),
            "text": JSON.from(text),
            "location": location,
        ])
    }

    public func build(stkId stkId: String, stkPkgId: String, stkVer: String) -> JSON {
        let metaData = JSON.from([
            "STKID": JSON.from(stkId),
            "STKPKGID": JSON.from(stkPkgId),
            "STKVER": JSON.from(stkVer),
        ])
        return JSON.from([
            "contentType": JSON.from(ContentType.Sticker.rawValue),
            "contentMetadata": metaData,
        ])
    }
}
