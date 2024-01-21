import UIKit
//Link: <https://api.unsplash.com/photos?page=1>; rel="first", <https://api.unsplash.com/photos?page=1>; rel="prev", <https://api.unsplash.com/photos?page=346>; rel="last", <https://api.unsplash.com/photos?page=3>; rel="next"

struct PhotoResult: Codable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: String?
    let description: String?
    let likedByUser: Bool //"liked_by_user"
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
    let welcomeDescription: String?// "description"
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool //"liked_by_user"
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
    
//При декодинге ответа с сервера нужно связать поле isLiked модели с полем liked_by_user ответа сервера.
