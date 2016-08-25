
import UIKit
import Messages

class DoodleBrowserViewController: MSStickerBrowserViewController {
    
    var stickers = [MSSticker]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stickerBrowserView.backgroundColor = UIColor.backgroundColor
        loadStickers()
    }
    
    // MARK: - Helpers
    
    private func loadStickers() {
        for url in DocumentsController.sharedController.stickerURLs() {
            do {
                let sticker = try MSSticker(contentsOfFileURL: url, localizedDescription: NSUUID().uuidString)
                stickers.append(sticker)
            }
            catch let error {
                print("Error creating sticker with url: \(url).\nError: \(error)")
            }
        }
    }
    
}

extension DoodleBrowserViewController {
    
    override func numberOfStickers(in stickerBrowserView: MSStickerBrowserView) -> Int {
        return stickers.count
    }
    
    override func stickerBrowserView(_ stickerBrowserView: MSStickerBrowserView, stickerAt index: Int) -> MSSticker {
        return stickers[index]
    }
    
}
