//
//  ViewController.swift
//  Instagrid
//
//  Created by Nicolas Perveaux on 05/07/2023.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // MARK: - Outlets
    
    
    // The 3 buttons to choose the grid
    @IBOutlet private var buttonOne: UIButton!
    @IBOutlet private var buttonTwo: UIButton!
    @IBOutlet private var buttonThree: UIButton!
    
    @IBOutlet weak var GridView: UIView!
    

    @IBOutlet weak var ArrowUp: UIImageView!
    @IBOutlet weak var SwipeUp: UILabel!
    @IBOutlet weak var ArrowLeft: UIImageView!
    @IBOutlet weak var SwipeLeft: UILabel!
    
    
    @IBOutlet weak var topLeftButton: UIButton!
    @IBOutlet weak var topRightButton: UIButton!
    @IBOutlet weak var bottomLeftButton: UIButton!
    @IBOutlet weak var bottomRightButton: UIButton!
    

    
    // MARK: - Properties et methodes

    var buttonTouch = UIButton()
    var imagePicker = UIImagePickerController()

    
    func startGridView() {
        buttonOneTapped("")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startGridView()
        swipeDirection()
    }
    
    
    // MARK: - Change Grid with 3 buttons
    
    func removeButtonsImages() {
        buttonOne.setImage(nil, for: UIControl.State.normal)
        buttonTwo.setImage(nil, for: UIControl.State.normal)
        buttonThree.setImage(nil, for: UIControl.State.normal)
    }
    
    @IBAction func buttonOneTapped(_ sender: Any) {
        if (buttonOne.currentImage == nil){
            removeButtonsImages()
            bottomRightButton.isEnabled = true;
            bottomRightButton.isHidden = false;
            buttonOne.setImage(UIImage(named: "Selected"), for: UIControl.State.normal)
            topRightButton.isEnabled = false;
            topRightButton.isHidden = true;
        }
    }
    
    @IBAction func buttonTwoTapped(_ sender: Any) {
        if (buttonTwo.currentImage == nil){
            removeButtonsImages()
            topRightButton.isEnabled = true;
            topRightButton.isHidden = false;
            buttonTwo.setImage(UIImage(named: "Selected"), for: UIControl.State.normal)
            bottomRightButton.isEnabled = false;
            bottomRightButton.isHidden = true;
        }
    }
    
    @IBAction func buttonThreeTapped(_ sender: Any) {
        if (buttonThree.currentImage == nil) {
            removeButtonsImages()
            topRightButton.isEnabled = true;
            bottomRightButton.isEnabled = true;
            buttonThree.setImage(UIImage(named: "Selected"), for: UIControl.State.normal)
            topRightButton.isHidden = false;
            bottomRightButton.isHidden = false;
        }
    }
    
    
    
    // MARK: - choose images

    @IBAction func GridTouch(_ sender: UIButton) {
        choseImage()
        buttonTouch = sender
       }
       
    func choseImage() {
           if (UIImagePickerController.isSourceTypeAvailable(.photoLibrary)) {
               imagePicker.delegate = self
               imagePicker.sourceType = .photoLibrary
               imagePicker.allowsEditing = false
               present(imagePicker, animated: true, completion: nil)
           }
       }
       
      func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
          picker.dismiss(animated: true, completion: nil)
          
       if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage { insertPickedImageIntoGrid(pickedImage) }
      }
       
       func insertPickedImageIntoGrid(_ image: UIImage) {
           buttonTouch.contentMode = .scaleAspectFit
           buttonTouch.setImage(image, for: UIControl.State.normal)
       }

    // MARK: - Swipe & Share

    
    func swipeDirection() {
        doSwipeGesture(to: ArrowUp, [.up])
        doSwipeGesture(to: SwipeUp, [.up])
        doSwipeGesture(to: ArrowLeft, [.left])
        doSwipeGesture(to: SwipeLeft, [.left])
        doSwipeGesture(to: GridView, [.up, .left])
    }
    
    func doSwipeGesture(to view: UIView, _ directions: [UISwipeGestureRecognizer.Direction]) {
        for direction in directions {
            let gesture = UISwipeGestureRecognizer (target: self, action: #selector(theSwipe(_:)))
            gesture.direction = direction
            view.addGestureRecognizer(gesture)
        }
    }
    
    func theSwipeValid (_ sender: UISwipeGestureRecognizer) -> Bool {
        return (sender.direction == .left && traitCollection.verticalSizeClass == .compact) || (sender.direction == .up && traitCollection.verticalSizeClass == .regular && traitCollection.horizontalSizeClass == .compact)
    }
    
    @objc func theSwipe (_ sender: UISwipeGestureRecognizer) {
        if theSwipeValid(sender) {
           var translation = CGAffineTransform();
            if (sender.direction == .up) {
               translation = CGAffineTransform(translationX: 0, y: -GridView.frame.maxY)
            }
            else if (sender.direction == .left){
                translation = CGAffineTransform(translationX: -GridView.frame.maxX, y: 0)
            }
            
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: [.curveEaseIn], animations: {
                self.GridView.transform = translation
                }, completion: { (end) in
                    let share = self.shareGridView(_sender: sender);
                    self.present(share, animated: true);
                }
            )
        }
    }
    
    func shareGridView (_sender: UISwipeGestureRecognizer) -> UIActivityViewController {
        let image = [self.GridView.image]
        let activityViewController = UIActivityViewController(activityItems: image as [Any], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = UIActivityViewController.CompletionWithItemsHandler? {
            activityType, completed, returnedItems, activitiyerror in
            
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0,options: [.curveEaseIn], animations: {
                self.GridView.transform = CGAffineTransform (translationX: 0, y: 0)
            },
            completion: nil)
            
        }
        return activityViewController
    }

}

extension UIView {   
    var image: UIImage? {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in layer.render(in: rendererContext.cgContext) }
    }
}

