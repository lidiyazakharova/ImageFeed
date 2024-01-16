import UIKit

struct PhotoResult: Codable {
    let page: String?
    let per_page: String?
    let order_by: String?
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


//При декодинге ответа с сервера нужно связать поле isLiked модели с полем liked_by_user ответа сервера.
