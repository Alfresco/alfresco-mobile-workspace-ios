//
// Copyright (C) 2005-2020 Alfresco Software Limited.
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

import Foundation
import UIKit
import AVFoundation

public typealias VideoPreviewHandler = (_ error: Error?) -> Void

class MediaPreview: UIView, FilePreviewProtocol {

    weak var filePreviewDelegate: FilePreviewDelegate?
    @IBOutlet weak var videoPlayerTapGesture: UITapGestureRecognizer!
    private var videoPreviewHandler: VideoPreviewHandler?

    @IBOutlet weak var videoPlayerView: UIView!
    @IBOutlet weak var actionsView: UIView!
    @IBOutlet weak var audioImageView: UIImageView!

    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var backwardButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var videoSlider: UISlider!
    @IBOutlet weak var currentTimeMinutesLabel: UILabel!
    @IBOutlet weak var currentTimeSecondsLabel: UILabel!
    @IBOutlet weak var currentTimeClockLabel: UILabel!
    @IBOutlet weak var totalTimeMinutesLabel: UILabel!
    @IBOutlet weak var totalTimeSecondsLabel: UILabel!
    @IBOutlet weak var totalTimeClockLabel: UILabel!

    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var timeObserver: Any?
    private var statusObserver: NSKeyValueObservation?
    private var rateObserver: NSKeyValueObservation?

    private var finishPlaying = false
    private var sliderIsMoving = false
    private var jumpPlayer = false
    private var isFullScreen = false {
        didSet {
            filePreviewDelegate?.enableFullScreen(isFullScreen)
            apply(fade: isFullScreen, to: actionsView)
        }
    }
    private var isAudioFile = false {
        didSet {
            audioImageView.isHidden = !isAudioFile
        }
    }

    private let playerJumpTime: Double = 10
    private var animationFade: TimeInterval = 0.3
    private let actionsViewCornerRadius: CGFloat = 8.0
    private let actionsViewBorderWidth: CGFloat = 1.0

    override func awakeFromNib() {
        super.awakeFromNib()
        translatesAutoresizingMaskIntoConstraints = false
        videoSlider.addTarget(self,
                                 action: #selector(onSliderValChanged(slider:event:)),
                                 for: .valueChanged)
        actionsView.layer.cornerRadius = actionsViewCornerRadius
        actionsView.layer.borderWidth = actionsViewBorderWidth
        actionsView.layer.masksToBounds = true
        playerControls(enable: false)
        audioImageView.image = UIImage(named: "ic-audio")
    }

    deinit {
        cancel()
    }

    // MARK: - IBActions

    @IBAction func videoPlayerTapped(_ sender: UITapGestureRecognizer) {
        isFullScreen = !isFullScreen
    }

    @IBAction func backwardButtonTapped(_ sender: UIButton) {
        jumpPlayerTime(with: -playerJumpTime)
    }

    @IBAction func forwardButtonTapped(_ sender: UIButton) {
        jumpPlayerTime(with: playerJumpTime)
    }

    @IBAction func playPauseTapped(_ sender: UIButton) {
        guard let player = player else { return }

        if finishPlaying {
            resetPlayer()
        }

        player.isPlaying ? player.pause() : player.play()
        UIApplication.shared.isIdleTimerDisabled = player.isPlaying

        if let error = player.currentItem?.error as NSError? {
            showError(error)
        } else {
            playerControls(enable: true)
            updatePlayerControls()
            apply(fade: false, to: actionsView)
        }
    }

    @IBAction func playbackSliderValueChanged(_ sender: UISlider) {
        guard let duration = player?.currentItem?.duration else { return }
        let value = Double(videoSlider.value) * duration.seconds
        player?.seek(to: CMTime(value: CMTimeValue(value), timescale: 1))

        if player?.rate == 0 {
            finishPlaying = false
            playPauseTapped(playPauseButton)
        }
    }

    @objc func onSliderValChanged(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                sliderIsMoving = true
                player?.pause()
                updatePlayerControls()
            case .moved:
                guard let currentItem = player?.currentItem else { return }
                updateCurrentTime(from: currentItem.duration.seconds * Double(videoSlider.value))
                updateTotalTime(from: currentItem.duration.seconds)
            case .ended:
                playbackSliderValueChanged(slider)
                sliderIsMoving = false
                player?.play()
                updatePlayerControls()
            default:
                break
            }
        }
    }

    // MARK: - Public Helpers

    func play(from url: URL, isAudioFile: Bool, handler: @escaping VideoPreviewHandler) {
        self.videoPreviewHandler = handler
        self.isAudioFile = isAudioFile

        let playerItem = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: playerItem)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = frame
        videoPlayerView.layer.addSublayer(playerLayer)

        self.playerLayer = playerLayer
        self.player = player

        let intervalTime = CMTime(seconds: 0.01, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player.addPeriodicTimeObserver(forInterval: intervalTime, queue: .main,
                                                       using: { [weak self] _ in
            guard let sSelf = self else { return }
            sSelf.updatePlayerState()
        })
        rateObserver = player.observe(\AVPlayer.rate, changeHandler: { [weak self] _, _ in
            guard let sSelf = self else { return }
            sSelf.updatePlayerControls()
        })
        statusObserver = playerItem.observe(\AVPlayerItem.status,
                                            changeHandler: { [weak self] cPlayerItem, _ in
            guard let sSelf = self else { return }
            if let error = cPlayerItem.error {
                handler(error)
                sSelf.playerControls(enable: false)
            } else {
                handler(nil)
                sSelf.playerControls(enable: true)
                sSelf.updateTotalTime(from: cPlayerItem.duration.seconds)
            }
        })
    }

    // MARK: - Private Helpers

    private func playerControls(enable: Bool) {
        videoPlayerTapGesture.isEnabled = enable
        videoSlider.isUserInteractionEnabled = enable
        actionsView.isHidden = !enable
    }

    private func showError(_ error: Error?) {
        actionsView.isUserInteractionEnabled = false
        var message = LocalizationConstants.Errors.somethingWentWrong
        if let error = error as NSError? {
            message = error.localizedFailureReason ?? error.localizedDescription
        }
        Snackbar.display(with: message, type: .error, finish: nil)
    }

    private func apply(fade: Bool, to object: UIView) {
        let fadeTo: CGFloat = (fade) ? 0.0 : 1.0
        UIView.animate(withDuration: animationFade) {
            object.alpha = fadeTo
        }
    }

    private func updatePlayerControls() {
        guard let player = player else { return }
        var stringImage = (player.isPlaying || jumpPlayer) ? "ic-player-pause" : "ic-player-play"
        if player.currentItem?.error != nil {
            stringImage = "ic-player-play"
        }
        playPauseButton.setImage(UIImage(named: stringImage), for: .normal)
    }

    private func jumpPlayerTime(with seconds: Double) {
        guard let currentTime = player?.currentTime(),
              let currentItem = player?.currentItem else { return }

        if currentTime.seconds + seconds >= currentItem.duration.seconds ||
            currentTime.seconds + seconds < 0 {
            return
        }

        playerControls(enable: true)
        jumpPlayer = true
        player?.pause()

        let newTime =  CMTimeGetSeconds(currentTime).advanced(by: seconds)
        player?.seek(to: CMTime(value: CMTimeValue(newTime), timescale: 1),
                     completionHandler: { [weak self] (_) in
            guard let sSelf = self else { return }
            sSelf.player?.play()
            sSelf.jumpPlayer = false
            UIApplication.shared.isIdleTimerDisabled = true
        })
    }

    private func updatePlayerState() {
        guard let currentTime = player?.currentTime(),
            let currentItem = player?.currentItem else { return }
        if let error = currentItem.error {
            showError(error)
        }
        updateCurrentTime(from: currentTime.seconds)
        updateTotalTime(from: currentItem.duration.seconds)

        if !self.sliderIsMoving {
            videoSlider.value = Float(currentTime.seconds / currentItem.duration.seconds)
        }
        if currentTime.seconds >= floor(currentItem.duration.seconds) {
            resetPlayer()
        }
    }

    private func resetPlayer() {
        player?.pause()
        player?.seek(to: CMTime(value: CMTimeValue(0.0), timescale: 1))
        updatePlayerControls()
        videoSlider.value = 0.0
        updateCurrentTime(from: 0)
        finishPlaying = false
    }

    private func updateCurrentTime(from seconds: Double) {
        let array = seconds.split(by: .minutesAndSeconds).split(separator: ":")
        if array.count == 2 {
            currentTimeMinutesLabel.text = String(array[0])
            currentTimeSecondsLabel.text = String(array[1])
        }
    }

    private func updateTotalTime(from seconds: Double) {
        let array = seconds.split(by: .minutesAndSeconds).split(separator: ":")
        if array.count == 2 {
            totalTimeMinutesLabel.text = String(array[0])
            totalTimeSecondsLabel.text = String(array[1])
        }
    }

    // MARK: - FilePreviewProtocol

    func applyComponentsThemes(_ currentTheme: PresentationTheme?) {
        guard let currentTheme = currentTheme else { return }

        currentTimeClockLabel.applyStyleBody2OnSurface(theme: currentTheme)
        currentTimeMinutesLabel.applyStyleBody2OnSurface(theme: currentTheme)
        currentTimeMinutesLabel.textAlignment = .right
        currentTimeSecondsLabel.applyStyleBody2OnSurface(theme: currentTheme)
        currentTimeSecondsLabel.textAlignment = .left

        totalTimeClockLabel.applyStyleBody2OnSurface(theme: currentTheme)
        totalTimeMinutesLabel.applyStyleBody2OnSurface(theme: currentTheme)
        totalTimeMinutesLabel.textAlignment = .right
        totalTimeSecondsLabel.applyStyleBody2OnSurface(theme: currentTheme)
        totalTimeSecondsLabel.textAlignment = .left

        videoSlider.tintColor = currentTheme.primaryT1Color
        videoSlider.thumbTintColor = currentTheme.primaryT1Color
        videoSlider.maximumTrackTintColor = currentTheme.primary30T1Color
        videoSlider.setThumbImage(UIImage(named: "ic-player-slider-thumb"), for: .normal)

        actionsView.backgroundColor = currentTheme.surfaceColor
        actionsView.layer.borderColor = currentTheme.onSurface15Color.cgColor

        backwardButton.tintColor = currentTheme.onSurface60Color
        forwardButton.tintColor = currentTheme.onSurface60Color

        playPauseButton.tintColor = currentTheme.primaryT1Color
        if isAudioFile {
            backgroundColor = currentTheme.backgroundColor
        }
    }
    
    func applyTheme(_ theme: CameraKitTheme?) {
        guard let theme = theme else { return }
        
        currentTimeClockLabel.textColor = theme.onSurfaceColor
        currentTimeClockLabel.font = theme.body2Font
        
        currentTimeMinutesLabel.textColor = theme.onSurfaceColor
        currentTimeMinutesLabel.font = theme.body2Font
        currentTimeMinutesLabel.textAlignment = .right
        
        currentTimeSecondsLabel.textColor = theme.onSurfaceColor
        currentTimeSecondsLabel.font = theme.body2Font
        currentTimeSecondsLabel.textAlignment = .left
        
        videoSlider.tintColor = theme.primaryColor
        videoSlider.thumbTintColor = theme.primaryColor
        videoSlider.maximumTrackTintColor = theme.primaryColor.withAlphaComponent(0.3)
        videoSlider.setThumbImage(UIImage(named: "ic-player-slider-thumb"), for: .normal)
        
        actionsView.backgroundColor = theme.surfaceColor
        actionsView.layer.borderColor = theme.onSurface15Color.cgColor

        backwardButton.tintColor = theme.onSurface60Color
        forwardButton.tintColor = theme.onSurface60Color

        playPauseButton.tintColor = theme.primaryColor
    }

    func recalculateFrame(from size: CGSize) {
        frame = CGRect(origin: .zero, size: size)
        playerLayer?.frame = frame
    }

    func cancel() {
        player?.pause()
        player = nil
        playerLayer?.removeFromSuperlayer()
        player?.removeTimeObserver(timeObserver as Any)
        player?.removeTimeObserver(statusObserver as Any)
        player?.removeTimeObserver(rateObserver as Any)
        timeObserver = nil
        statusObserver = nil
        rateObserver = nil
        UIApplication.shared.isIdleTimerDisabled = false
    }
}
