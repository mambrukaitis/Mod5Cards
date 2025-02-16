//used for dragging and dropping items into the card, decides whether its an image or text, uses corresponding code

import SwiftUI

struct CustomTransfer: Transferable {
    var image: UIImage?
    var text: String?
    
    public static var transferRepresentation: some
    TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            let image = UIImage(data: data)
                ?? UIImage(named: "error-image")
            return CustomTransfer(image: image)
        }
        DataRepresentation(importedContentType: .text) { data in
            let text = String(decoding: data, as: UTF8.self)
            return CustomTransfer(text: text)
        }
    }
}
