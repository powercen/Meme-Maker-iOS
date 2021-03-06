//
//  MemesCollectionViewCell.swift
//  Meme Maker
//
//  Created by Avikant Saini on 4/4/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

import UIKit
import SDWebImage

private enum CellMode {
	case Meme
	case Created
	case UserCreation
}

class MemesCollectionViewCell: UICollectionViewCell {
	
	var meme: XMeme? = nil {
		didSet {
			self.memeNameLabel.text = meme?.name
		}
	}
	
	var isListCell: Bool = true {
		didSet {
			self.setNeedsDisplay()
			tintColor = globalTintColor
			memeNameLabel.textColor = globalTintColor
			backgroundColor = globalBackColor
			self.updateImageView()
		}
	}

	@IBOutlet weak var memeImageView: UIImageView!
	@IBOutlet weak var memeNameLabel: UILabel!
	@IBOutlet weak var labelContainerView: UIView!
	
	override func drawRect(rect: CGRect) {
		
		if (isListCell) {
			
			if isDarkMode() {
				UIColor.darkGrayColor().setStroke()
			}
			else {
				UIColor.lightGrayColor().setStroke()
			}
			
			// Disclosure
			let disclosurePath = UIBezierPath()
			disclosurePath.lineWidth = 1.0;
			disclosurePath.lineCapStyle = .Round
			disclosurePath.lineJoinStyle = .Round
			disclosurePath.moveToPoint(CGPointMake(self.frame.width - 20, self.frame.height/2 - 6))
			disclosurePath.addLineToPoint(CGPointMake(self.frame.width - 15, self.frame.height/2))
			disclosurePath.addLineToPoint(CGPointMake(self.frame.width - 20, self.frame.height/2 + 6))
			disclosurePath.stroke()

			// Separator
			let beizerPath = UIBezierPath()
			beizerPath.lineWidth = 0.5
			beizerPath.lineCapStyle = .Round
			beizerPath.moveToPoint(CGPointMake(self.bounds.height + 8, self.bounds.height - 0.5))
			beizerPath.addLineToPoint(CGPointMake(self.bounds.width, self.bounds.height - 0.5))
			beizerPath.stroke()
		}
		
	}
	
	func updateImageView() -> Void {
		
		let filePath = imagesPathForFileName("\(self.meme!.memeID)")
		if (NSFileManager.defaultManager().fileExistsAtPath(filePath)) {
			if (self.isListCell) {
				let filePathC = imagesPathForFileName("\(self.meme!.memeID)c")
				if (NSFileManager.defaultManager().fileExistsAtPath(filePathC)) {
					self.memeImageView.image = UIImage(contentsOfFile: filePathC)
				}
				else {
					let image = getCircularImage(UIImage(contentsOfFile: filePath)!)
					let data = UIImagePNGRepresentation(image)
					data?.writeToFile(filePathC, atomically: true)
					self.memeImageView.image = image
				}
			}
			else {
				let filePathS = imagesPathForFileName("\(self.meme!.memeID)s")
				if (NSFileManager.defaultManager().fileExistsAtPath(filePathS)) {
					self.memeImageView.image = UIImage(contentsOfFile: filePathS)
				}
				else {
					let image = getSquareImage(UIImage(contentsOfFile: filePath)!)
					let data = UIImagePNGRepresentation(image)
					data?.writeToFile(filePathS, atomically: true)
					self.memeImageView.image = image
				}
			}
		}
		else {
			self.memeImageView.image = UIImage(named: "MemeBlank")
			if let URLString = meme?.image {
				if let URL = NSURL(string: URLString) {
//					print("Downloading image \'\(meme!.memeID)\'")
					self.downloadImageWithURL(URL, filePath: filePath)
				}
			}
		}
		
	}
	
	func downloadImageWithURL(URL: NSURL, filePath: String) -> Void {
		SDWebImageDownloader.sharedDownloader().downloadImageWithURL(URL, options: .ProgressiveDownload, progress: nil, completed: { (image, data, error, success) in
			if (success && error == nil) {
				data.writeToFile(filePath, atomically: true)
				dispatch_async(dispatch_get_main_queue(), {
					self.updateImageView()
				})
			}
		})
	}
	
}
