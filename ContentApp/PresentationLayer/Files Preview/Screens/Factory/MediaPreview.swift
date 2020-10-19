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

class MediaPreview: UIView, FilePreviewProtocol {

    weak var filePreviewDelegate: FilePreviewDelegate?
    @IBOutlet weak var videoPlayerTapGesture: UITapGestureRecognizer!

    @IBOutlet weak var videoPlayerView: UIView!
    @IBOutlet weak var actionsView: UIView!
    @IBOutlet weak var audioImageView: UIImageView!

    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var backwardButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var bigPlayPauseButton: UIButton!
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
    private var isFullScreen: Bool = false {
        didSet {
            if !isAudioFile {
                filePreviewDelegate?.enableFullScreen(isFullScreen)
                apply(fade: isFullScreen, to: actionsView)
            }
        }
    }
    private var isAudioFile: Bool = false {
        didSet {
            audioImageView.isHidden = !isAudioFile
            if isAudioFile {
                actionsView.isHidden = false
                actionsView.alpha = 1.0
                bigPlayPauseButton.alpha = 0.0
            }
        }
    }

    override func awakeFromNib() {
        videoPlayerTapGesture.isEnabled = false
        translatesAutoresizingMaskIntoConstraints = false
        progressSlider.isUserInteractionEnabled = false
        progressSlider.addTarget(self,
                                 action: #selector(onSliderValChanged(slider:event:)),
                                 for: .valueChanged)
        actionsView.layer.cornerRadius = 8.0
        actionsView.layer.borderWidth = 1.0
        actionsView.layer.masksToBounds = true
    }

    deinit {
        cancel()
    }

    // MARK: - IBActions

    @IBAction func videoPlayerTapped(_ sender: UITapGestureRecognizer) {
        isFullScreen = !isFullScreen
    }

    @IBAction func backwardButtonTapped(_ sender: UIButton) {
        advancedPlayerTime(with: -kPlayerBackForWardTime)
    }

    @IBAction func forwardButtonTapped(_ sender: UIButton) {
        advancedPlayerTime(with: kPlayerBackForWardTime)
    }

    @IBAction func playPauseTapped(_ sender: UIButton) {
        guard let player = player else { return }

        if finishPlaying {
            player.seek(to: CMTime(value: CMTimeValue(0.0), timescale: 1))
            finishPlaying = false
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
            apply(fade: true, to: bigPlayPauseButton)
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
                let totalTimeInSeconds = currentTimeInSeconds - currentItem.duration.seconds

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

    func play(from url: URL, isAudioFile: Bool) {
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
                                            changeHandler: { [weak self] playerItem, _ in
            guard let sSelf = self else { return }
            switch playerItem.status {
            case .readyToPlay:
                sSelf.updateTotalTime(from: sSelf.timeFormatter(from: playerItem.duration.seconds))
            case .failed:
                sSelf.showError(playerItem.error)
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
        guard !isAudioFile else { return }
        let fadeTo: CGFloat = (fade) ? 0.0 : 1.0
        UIView.animate(withDuration: animationFade) {
            object.alpha = fadeTo
        }
    }

    private func updatePlayerControls() {
        guard let player = player else { return }
        var stringImage = player.isPlaying ? "player_small_pause" : "player_small_play"
        if player.currentItem?.error != nil {
            stringImage = "player_small_play"
        }
        playPauseButton.setImage(UIImage(named: stringImage), for: .normal)
    }

    private func advancedPlayerTime(with seconds: Double) {
        guard let currentTime = player?.currentTime() else { return }
        let newTime =  CMTimeGetSeconds(currentTime).advanced(by: seconds)
        let seekTime = CMTime(value: CMTimeValue(newTime), timescale: 1)
        player?.seek(to: seekTime)
    }

    private func updatePlayerState() {
        guard let currentTime = player?.currentTime(),
            let currentItem = player?.currentItem else { return }
        if let error = currentItem.error {
            showError(error)
        }
        let currenTimeInSeconds = currentTime.seconds
        let totalTimeInSeconds = currentTime.seconds - currentItem.duration.seconds
        updateCurrentTime(from: timeFormatter(from: currenTimeInSeconds))
        updateTotalTime(from: timeFormatter(from: totalTimeInSeconds))

        if !self.sliderIsMoving {
            progressSlider.value = Float(currentTime.seconds / currentItem.duration.seconds)
        }
        if currentTime.seconds == currentItem.duration.seconds {
            updatePlayerControls()
            apply(fade: false, to: bigPlayPauseButton)
            finishPlaying = true
        }
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
        progressSlider.setThumbImage(UIImage(named: "player_sliderThumb"), for: .normal)

        actionsView.backgroundColor = currentTheme.surfaceColor
        actionsView.layer.borderColor = currentTheme.onSurfaceColor.withAlphaComponent(0.12).cgColor

        backwardButton.tintColor = currentTheme.onSurfaceColor.withAlphaComponent(0.6)
        forwardButton.tintColor = currentTheme.onSurfaceColor.withAlphaComponent(0.6)

        playPauseButton.tintColor = currentTheme.primaryColor
    }

    func recalculateFrame(from size: CGSize) {
        frame = CGRect(origin: .zero, size: size)
        playerLayer?.frame = frame
    }

    func cancel() {
        player?.pause()
        player = nil
        playerLayer?.removeFromSuperlayer()
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
        }
        self.timeObserver = nil
        self.statusObserver = nil
        self.rateObserver = nil
        UIApplication.shared.isIdleTimerDisabled = false
    }
}
