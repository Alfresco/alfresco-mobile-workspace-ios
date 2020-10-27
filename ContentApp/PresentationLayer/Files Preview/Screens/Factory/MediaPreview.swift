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
    @IBOutlet weak var progressSlider: UISlider!
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
    private var animationFade: TimeInterval = 0.3

    private var finishPlaying: Bool = false
    private var sliderIsMoving: Bool = false
    private var jumpPlayer: Bool = false
    private var isFullScreen: Bool = false {
        didSet {
            filePreviewDelegate?.enableFullScreen(isFullScreen)
            apply(fade: isFullScreen, to: actionsView)
        }
    }
    private var isAudioFile: Bool = false {
        didSet {
            audioImageView.isHidden = !isAudioFile
        }
    }

    override func awakeFromNib() {
        videoPlayerTapGesture.isEnabled = false
        translatesAutoresizingMaskIntoConstraints = false
        progressSlider.isUserInteractionEnabled = false
        progressSlider.addTarget(self,
                                 action: #selector(onSliderValChanged(slider:event:)),
                                 for: .valueChanged)
        actionsView.layer.cornerRadius = dialogCornerRadius
        actionsView.layer.borderWidth = 1.0
        actionsView.layer.masksToBounds = true
        actionsView.isHidden = true
    }

    deinit {
        cancel()
    }

    // MARK: - IBActions

    @IBAction func videoPlayerTapped(_ sender: UITapGestureRecognizer) {
        isFullScreen = !isFullScreen
    }

    @IBAction func backwardButtonTapped(_ sender: UIButton) {
        jumpPlayerTime(with: -kPlayerBackForWardTime)
    }

    @IBAction func forwardButtonTapped(_ sender: UIButton) {
        jumpPlayerTime(with: kPlayerBackForWardTime)
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
            progressSlider.isUserInteractionEnabled = true
            videoPlayerTapGesture.isEnabled = true
            updatePlayerControls()
            actionsView.isHidden = false
            apply(fade: false, to: actionsView)
        }
    }

    @IBAction func playbackSliderValueChanged(_ sender: UISlider) {
        guard let duration = player?.currentItem?.duration else { return }
        let value = Double(progressSlider.value) * duration.seconds
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
                let sliderValue = Double(progressSlider.value)
                let currentTimeInSeconds = currentItem.duration.seconds * sliderValue
                let totalTimeInSeconds = currentItem.duration.seconds

                updateCurrentTime(from: timeFormatter(from: currentTimeInSeconds))
                updateTotalTime(from: timeFormatter(from: totalTimeInSeconds))
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
            switch cPlayerItem.status {
            case .readyToPlay:
                sSelf.actionsView.isHidden = false
                sSelf.updateTotalTime(from: sSelf.timeFormatter(from: cPlayerItem.duration.seconds))
                if let handler = sSelf.videoPreviewHandler {
                    handler(nil)
                }
            case .failed:
                if let handler = sSelf.videoPreviewHandler {
                    handler(playerItem.error)
                }
            default: break
            }
        })
    }

    // MARK: - Private Helpers

    private func showError(_ error: Error?) {
        actionsView.isUserInteractionEnabled = false
        var message = LocalizationConstants.Errors.somethingWentWrong
        if let error = error as NSError? {
            message = error.localizedFailureReason ?? error.localizedDescription
        }
        let snackbar = Snackbar(with: message, type: .error, automaticallyDismisses: true)
        snackbar.show(completion: nil)
    }

    private func apply(fade: Bool, to object: UIView) {
        let fadeTo: CGFloat = (fade) ? 0.0 : 1.0
        UIView.animate(withDuration: animationFade) {
            object.alpha = fadeTo
        }
    }

    private func updatePlayerControls() {
        guard let player = player else { return }
        var stringImage = player.isPlaying ? "ic-player-pause" : "ic-player-play"
        if player.currentItem?.error != nil {
            stringImage = "ic-player-play"
        }
        if jumpPlayer {
            stringImage = "ic-player-pause"
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

        progressSlider.isUserInteractionEnabled = true
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
        let currenTimeInSeconds = currentTime.seconds
        let totalTimeInSeconds = currentItem.duration.seconds
        updateCurrentTime(from: timeFormatter(from: currenTimeInSeconds))
        updateTotalTime(from: timeFormatter(from: totalTimeInSeconds))

        if !self.sliderIsMoving {
            progressSlider.value = Float(currentTime.seconds / currentItem.duration.seconds)
        }
        if currentTime.seconds >= floor(currentItem.duration.seconds) {
            resetPlayer()
        }
    }

    private func resetPlayer() {
        player?.pause()
        player?.seek(to: CMTime(value: CMTimeValue(0.0), timescale: 1))
        updatePlayerControls()
        progressSlider.value = 0.0
        updateCurrentTime(from: timeFormatter(from: 0))
        finishPlaying = false
    }

    private func updateCurrentTime(from text: String) {
        let array = text.split(separator: ":")
        if array.count == 2 {
            currentTimeMinutesLabel.text = String(array[0])
            currentTimeSecondsLabel.text = String(array[1])
        }
    }

    private func updateTotalTime(from text: String) {
        let array = text.split(separator: ":")
        if array.count == 2 {
            totalTimeMinutesLabel.text = String(array[0])
            totalTimeSecondsLabel.text = String(array[1])
        }
    }

    private func timeFormatter(from seconds: Double) -> String {
        let mins = seconds / 60
        let secs = seconds.truncatingRemainder(dividingBy: 60)
        let timeformatter = NumberFormatter()
        timeformatter.minimumIntegerDigits = 2
        timeformatter.minimumFractionDigits = 0
        timeformatter.roundingMode = .down
        guard let minsStr = timeformatter.string(from: NSNumber(value: mins)),
            let secsStr = timeformatter.string(from: NSNumber(value: secs))
            else { return "00:00" }
        let time = "\(minsStr):\(secsStr)".replacingOccurrences(of: "-", with: "")
        if time.contains("NaN") {
            return "00:00"
        }
        return time
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

        progressSlider.tintColor = currentTheme.primaryColor
        progressSlider.thumbTintColor = currentTheme.primaryColor
        progressSlider.maximumTrackTintColor = currentTheme.primaryColor.withAlphaComponent(0.4)
        progressSlider.setThumbImage(UIImage(named: "ic-player-slider-thumb"), for: .normal)

        actionsView.backgroundColor = currentTheme.surfaceColor
        actionsView.layer.borderColor = currentTheme.onSurfaceColor.withAlphaComponent(0.12).cgColor

        backwardButton.tintColor = currentTheme.onSurfaceColor.withAlphaComponent(0.6)
        forwardButton.tintColor = currentTheme.onSurfaceColor.withAlphaComponent(0.6)

        playPauseButton.tintColor = currentTheme.primaryColor
        if isAudioFile {
            backgroundColor = currentTheme.backgroundColor
        }
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
