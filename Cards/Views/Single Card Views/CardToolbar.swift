/// Copyright (c) 2023 Kodeco
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SwiftUI

struct CardToolbar: ViewModifier {
  @Environment(\.dismiss) var dismiss
  @Binding var currentModal: ToolbarSelection?
  @Binding var card: Card
  @State private var stickerImage: UIImage?
    @EnvironmentObject var store: CardStore
    @State private var frameIndex: Int?
    @State private var textElement = TextElement()

    var menu: some View {
        Menu {
            Button {
                if UIPasteboard.general.hasImages {
                    if let images = UIPasteboard.general.images {
                        for image in images {
                            card.addElement(uiImage: image)
                        }
                    }
                } else if UIPasteboard.general.hasStrings {
                    if let strings = UIPasteboard.general.strings {
                        for text in strings {
                            card.addElement(text: TextElement(text: text))
                        }
                    }
                }
            } label: {
                Label("Paste", systemImage: "doc.on.clipboard")
            }
            .disabled(!UIPasteboard.general.hasImages && !UIPasteboard.general.hasStrings)
        } label: {
            Label("Add", systemImage: "ellipsis.circle")
        }
    }
    
  func body(content: Content) -> some View {
    content
      .toolbar {
          ToolbarItem(placement: .navigationBarTrailing) {
            menu
        }
          ToolbarItem(placement: .navigationBarTrailing) {
              Button("Done") {
                  dismiss()
              }
        }
          ToolbarItem(placement: .navigationBarLeading) {
              let uiImage = UIImage.screenshot(
                card: card,
                size: Settings.cardSize)
              let image = Image(uiImage: uiImage)
              ShareLink(
                item: image,
                preview: SharePreview("Card", image: image)) {
                    Image(systemName: "square.and.arrow.up")
                }
          }
          ToolbarItem(placement: .bottomBar) {
              BottomToolbar(
                modal: $currentModal,
                card: $card)
          }
      }
      .sheet(item: $currentModal) { item in
        switch item {
        case .stickerModal:
          StickerModal(stickerImage: $stickerImage)
            .onDisappear {
              if let stickerImage = stickerImage {
                card.addElement(uiImage: stickerImage)
              }
              stickerImage = nil
            }
            case .frameModal:
            FrameModal(frameIndex: $frameIndex)
                .onDisappear {
                    if let frameIndex {
                        card.update(
                            store.selectedElement,
                            frameIndex: frameIndex)
                    }
                    frameIndex = nil
                }
        case .textModal:
            TextModal(textElement: $textElement)
                .onDisappear {
                    if !textElement.text.isEmpty {
                        card.addElement(text: textElement)
                    }
                    textElement = TextElement()
                }
        default:
          Text(String(describing: item))
        }
      }
  }
}
