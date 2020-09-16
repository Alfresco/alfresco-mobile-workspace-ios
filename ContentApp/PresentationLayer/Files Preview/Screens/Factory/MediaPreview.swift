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

    weak var delegate: FilePreviewDelegate?

    @IBOutlet weak var videoPlayerView: UIView!
    @IBOutlet weak var actionsView: UIView!
    @IBOutlet weak var audioImageView: UIImageView!

    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var bigPlayPauseButton: UIButton!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!

    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var timeObserver: Any?
    private var url: URL?
    private var animationFade: TimeInterval = 1.0

    private var finishPlaying: Bool = false
    private var sliderIsMoving: Bool = false
    private var isFullScreen: Bool = false {
        didSet {
            if !isAudioFile {
                delegate?.applyFullScreen(isFullScreen)
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
                appDelegate?.allowedOrientation = .portrait
            }
        }
    }

    override func awakeFromNib() {
        translatesAutoresizingMaskIntoConstraints = false
        actionsView.isHidden = true
        progressSlider.addTarget(self,
                                 action: #selector(onSliderValChanged(slider:event:)),
                                 for: .valueChanged)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - IBActions

    @IBAction func videoPlayerTapGesture(_ sender: UITapGestureRecognizer) {
        isFullScreen = !isFullScreen
    }

    @IBAction func playPauseTapped(_ sender: UIButton) {
        guard let player = player else { return }

        if finishPlaying {
            player.seek(to: CMTime(value: CMTimeValue(0.0), timescale: 1))
            finishPlaying = false
        }

        player.isPlaying ? player.pause() : player.play()
        changeIconPlayPauseButton()
        actionsView.isHidden = false
        apply(fade: true, to: bigPlayPauseButton)
        apply(fade: false, to: actionsView)
    }

    @IBAction func playbackSliderValueChanged(_ sender: UISlider) {
        guard let duration = player?.currentItem?.duration else { return }
        let value = Float64(progressSlider.value) * CMTimeGetSeconds(duration)
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
                changeIconPlayPauseButton()
            case .moved:
                guard let currentItem = player?.currentItem else { return }
                let currentTimeInSeconds = Float(CMTimeGetSeconds(currentItem.duration)) * progressSlider.value
                currentTimeLabel.text = timeFormatter(from: Float64(currentTimeInSeconds))
            case .ended:
                playbackSliderValueChanged(slider)
                sliderIsMoving = false
                player?.play()
                changeIconPlayPauseButton()
            default:
                break
            }
        }
    }

    // MARK: - Public Helpers

    func play(from url: URL, isAudioFile: Bool) {
        self.url = url
        self.isAudioFile = isAudioFile

        let player = AVPlayer(url: url)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = frame
        videoPlayerView.layer.addSublayer(playerLayer)

        self.playerLayer = playerLayer
        self.player = player

        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.01,
                                                                          preferredTimescale: CMTimeScale(NSEC_PER_SEC)),
                                                       queue: .main,
                                                       using: { [weak self] _ in
                guard let sSelf = self else { return }
                sSelf.updateVideoPlayerState()
        })
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerDidFinishPlaying(_:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: player.currentItem)
        player.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions(rawValue: 0), context: nil)
    }

    // MARK: - Private Helpers

    @objc private func playerDidFinishPlaying(_ notification: NSNotification) {
        changeIconPlayPauseButton()
        bigPlayPauseButton.alpha = 1.0
        finishPlaying = true
    }

    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?, change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        if keyPath == "rate" {
            changeIconPlayPauseButton()
        }
    }

    private func apply(fade: Bool, to object: UIView) {
        guard !isAudioFile else { return }
        let fadeTo: CGFloat = (fade) ? 0.0 : 1.0
        UIView.animate(withDuration: animationFade) {
            object.alpha = fadeTo
        }
    }

    private func changeIconPlayPauseButton() {
        guard let player = player else { return }
        playPauseButton.setImage(UIImage(named: player.isPlaying ? "pause" : "play"), for: .normal)
        bigPlayPauseButton.setImage(UIImage(named: player.isPlaying ? "pause" : "bigPlay"), for: .normal)
    }

    private func updateVideoPlayerState() {
        guard let currentTime = player?.currentTime(), let currentItem = player?.currentItem else { return }
        let currentTimeInSeconds = CMTimeGetSeconds(currentTime)
        let durationTimeInSeconds = CMTimeGetSeconds(currentItem.duration)
        currentTimeLabel.text = timeFormatter(from: currentTimeInSeconds)
        totalTimeLabel.text = timeFormatter(from: durationTimeInSeconds)
        if !self.sliderIsMoving {
            progressSlider.value = Float(CMTimeGetSeconds(currentTime) / CMTimeGetSeconds(currentItem.duration))
        }
    }

    private func timeFormatter(from seconds: Float64) -> String {
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

    func applyComponentsThemes(themingService: MaterialDesignThemingService) {
        guard let currentTheme = themingService.activeTheme else { return }
        totalTimeLabel.applyStyleCaptionSurface60(theme: currentTheme)
        totalTimeLabel.textAlignment = .center
        currentTimeLabel.applyStyleCaptionSurface60(theme: currentTheme)
        currentTimeLabel.textAlignment = .center
        actionsView.backgroundColor = currentTheme.onSurfaceColor
        playPauseButton.tintColor = currentTheme.surfaceColor
        bigPlayPauseButton.tintColor = currentTheme.surfaceColor
        progressSlider.tintColor = currentTheme.primaryColor
        progressSlider.thumbTintColor = currentTheme.primaryVariantColor
        audioImageView.tintColor = currentTheme.onSurfaceColor
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
            self.timeObserver = nil
        }
    }
}
