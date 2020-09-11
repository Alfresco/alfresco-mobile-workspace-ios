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
    @IBOutlet weak var videoPlayerView: UIView!
    @IBOutlet weak var actionsView: UIView!
    @IBOutlet weak var audioImageView: UIImageView!

    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var bigPlayPauseButton: UIButton!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var remainingTimeLabel: UILabel!

    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var timeObserver: Any?
    private var url: URL?
    private var animationFade: TimeInterval = 1.0
    private var finishPlaying: Bool = false
    private var isAudioFile: Bool = false {
        didSet {
            if isAudioFile {
                actionsView.alpha = 1.0
                bigPlayPauseButton.alpha = 0.0
            }
        }
    }

    override func awakeFromNib() {
        actionsView.alpha = 0.0
    }

    // MARK: - IBActions

    @IBAction func videoPlayerTapGesture(_ sender: UITapGestureRecognizer) {
        apply(fade: (actionsView.alpha == 1), to: actionsView)
    }

    @IBAction func playPauseTapped(_ sender: UIButton) {
        guard let player = player else { return }

        if finishPlaying {
            player.seek(to: CMTime(value: CMTimeValue(0.0), timescale: 1))
            finishPlaying = false
        }

        player.isPlaying ? player.pause() : player.play()
        playPauseButton.setImage(UIImage(named: player.isPlaying ? "pause" : "play"), for: .normal)
        bigPlayPauseButton.setImage(UIImage(named: player.isPlaying ? "pause" : "play"), for: .normal)
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

    // MARK: - Public Helpers

    func play(from url: URL, isAudioFile: Bool) {
        self.url = url
        self.isAudioFile = isAudioFile

        audioImageView.isHidden = !isAudioFile

        player = AVPlayer(url: url)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = videoPlayerView.bounds
        videoPlayerView.layer.addSublayer(playerLayer)
        self.playerLayer = playerLayer

        let interval = CMTime(seconds: 0.01, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval,
                                                       queue: DispatchQueue.main,
                                                       using: { [weak self] _ in
            guard let sSelf = self else { return }
            sSelf.updateVideoPlayerState()
        })
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerDidFinishPlaying(_:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: player?.currentItem)
    }

    func applyComponentsThemes(themingService: MaterialDesignThemingService) {
    }

    func recalculateFrame(from size: CGSize) {
        frame = CGRect(origin: .zero, size: size)
        playerLayer?.frame = videoPlayerView.bounds
    }

    func cancel() {
        player?.pause()
        player = nil
        playerLayer?.removeFromSuperlayer()
        timeObserver = nil
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Private Helperspo

    @objc private func playerDidFinishPlaying(_ notification: NSNotification) {
        playPauseButton.setImage(UIImage(named: "play"), for: .normal)
        bigPlayPauseButton.setImage(UIImage(named: "play"), for: .normal)
        bigPlayPauseButton.alpha = 1.0
        finishPlaying = true
    }

    private func apply(fade: Bool, to object: UIView) {
        guard !isAudioFile else { return }
        let fadeTo: CGFloat = (fade) ? 0.0 : 1.0
        UIView.animate(withDuration: animationFade) {
            object.alpha = fadeTo
        }
    }

    private func updateVideoPlayerState() {
        guard let currentTime = player?.currentTime() else { return }
        let currentTimeInSeconds = CMTimeGetSeconds(currentTime)
//        progressSlider.value = Float(currentTimeInSeconds)
        if let currentItem = player?.currentItem {
            let duration = currentItem.duration
            guard !CMTIME_IS_INVALID(duration) else { return }
            let currentTime = currentItem.currentTime()
            progressSlider.value = Float(CMTimeGetSeconds(currentTime) / CMTimeGetSeconds(duration))
            updateTime(from: duration, and: currentTimeInSeconds)
        }
    }

    private func updateTime(from duration: CMTime, and currentTimeInSeconds: Float64) {
        currentTimeLabel.text = timeFormatter(from: currentTimeInSeconds)
        remainingTimeLabel.text = timeFormatter(from: CMTimeGetSeconds(duration))
    }

    private func timeFormatter(from seconds: Float64) -> String {
        let mins = seconds / 60
        let secs = seconds.truncatingRemainder(dividingBy: 60)
        let timeformatter = NumberFormatter()
        timeformatter.minimumIntegerDigits = 2
        timeformatter.minimumFractionDigits = 0
        timeformatter.roundingMode = .down
        guard let minsStr = timeformatter.string(from: NSNumber(value: mins)),
            let secsStr = timeformatter.string(from: NSNumber(value: secs)) else { return "" }
        return "\(minsStr):\(secsStr)".replacingOccurrences(of: "-", with: "")
    }
}
