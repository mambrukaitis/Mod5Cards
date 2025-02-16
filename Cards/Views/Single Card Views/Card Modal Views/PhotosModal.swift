
//opens the photopicker and stores the slected image identifiers in the array

import SwiftUI
import PhotosUI

struct PhotosModal: View {
    @Binding var card: Card
    @State private var selectedItems: [PhotosPickerItem] = []
    
    var body: some View {
        PhotosPicker(
            selection: $selectedItems,
            matching: .images) {
                //uses the image from the BottomToolbar
                ToolbarButton(modal: .photoModal)
            }
            .onChange(of: selectedItems) { items in
                for item in items {
                    item.loadTransferable(type: Data.self) { result in
                        Task {
                            switch result {
                            case .success(let data):
                                if let data,
                                   let uiImage = UIImage(data: data) {
                                    card.addElement(uiImage: uiImage)
                                }
                            case .failure(let failure):
                                fatalError("Image transfer failed: \(failure)")
                            }
                        }
                    }
                }
                selectedItems = []
            }
    }
}

#Preview {
    PhotosModal(card: .constant(Card()))
}
