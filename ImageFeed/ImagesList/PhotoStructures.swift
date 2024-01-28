import UIKit

struct SinglePhotoResult: Codable {
    let photo: PhotoResult
}

struct PhotoResult: Codable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: String?
    let description: String?
    let likedByUser: Bool
    let urls: UrlsResult?
}

struct UrlsResult: Codable {
    let raw: String?
    let full: String?
    let regular: String?
    let small: String?
    let thumb: String?
}
    
struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

extension Photo {
    init(result photo: PhotoResult) {
        self.init(
            id: photo.id,
            size: CGSize(width: photo.width, height: photo.height),
            createdAt: ISO8601DateFormatter().date(from: photo.createdAt ?? ""),
            welcomeDescription: photo.description,
            thumbImageURL: photo.urls?.thumb ?? "",
            largeImageURL: photo.urls?.full ?? "",
            isLiked: photo.likedByUser
        )
    }
}
