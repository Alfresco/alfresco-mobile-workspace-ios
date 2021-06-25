//
// Copyright (C) 2005-2021 Alfresco Software Limited.
//
// This file is part of the Alfresco Content Mobile iOS App.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit

class FullScreenVideoViewController: UIViewController {
    var videoPreview: MediaPreview?
    @IBOutlet weak var closeButton: UIButton!
    
    var videoURL: URL?
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        closeButton.layer.cornerRadius = closeButton.bounds.height / 2.0
        
        if let mediaPreview: MediaPreview = .fromNib(), let url = videoURL {
            mediaPreview.frame = CGRect(origin: .zero, size: view.bounds.size)
            mediaPreview.play(from: url, isAudioFile: false) { (error) in
                
            }
            view.addSubview(mediaPreview)
            
            NSLayoutConstraint.activate([
                mediaPreview.topAnchor.constraint(equalTo: view.topAnchor,
                                                      constant: 0),
                mediaPreview.leftAnchor.constraint(equalTo: view.leftAnchor,
                                                       constant: 0),
                mediaPreview.rightAnchor.constraint(equalTo: view.rightAnchor,
                                                        constant: 0),
                mediaPreview.bottomAnchor.constraint(equalTo: view.bottomAnchor,
                                                         constant: 0)
            ])
            
            videoPreview = mediaPreview
        }
        view.bringSubviewToFront(closeButton)
        applyComponentsThemes()
    }
    
    // MARK: - IBActions
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Private Methods
    
    private func applyComponentsThemes() {
        view.backgroundColor = .black
        closeButton.tintColor = .white
        closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.6)
    }
    
}
