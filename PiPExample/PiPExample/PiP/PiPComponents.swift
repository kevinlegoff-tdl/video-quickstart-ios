//
//  PiPComponents.swift
//  PiPExample
//
//  Created by Kevin LE GOFF on 18/09/2023.
//

import Foundation
import AVKit
import TwilioVideo
import UIKit

class PIPPlaceholderView: UIView {
    let label = UILabel()

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        addSubview(label)

        label.textColor = .white
        label.textAlignment = .center
    }

    override func didMoveToSuperview() {
        guard let superview = superview else {
            NSLog("[Kevin] PIPPlaceholderView didMoveToSuperview but superview is nil")
            return
        }

        translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            topAnchor.constraint(equalTo: superview.topAnchor),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)

        label.translatesAutoresizingMaskIntoConstraints = false
        let labelConstraints = [
            leadingAnchor.constraint(equalTo: label.leadingAnchor),
            trailingAnchor.constraint(equalTo: label.trailingAnchor),
            topAnchor.constraint(equalTo: label.topAnchor),
            bottomAnchor.constraint(equalTo: label.bottomAnchor)
        ]
        NSLayoutConstraint.activate(labelConstraints)
    }

    func configure(participantName: String) {
        label.text = participantName
    }
}


class PictureInPictureSetupView: UIView {
    var videoView: VideoTrackStoringSampleBufferVideoView!
    var placeholderView: PIPPlaceholderView!
    private var pipController: AVPictureInPictureController!
    private var pipVideoCallViewController: AVPictureInPictureVideoCallViewController!

    override init(frame: CGRect) {
        super.init(frame: frame)

        videoView = VideoTrackStoringSampleBufferVideoView()
        videoView.contentMode = .scaleAspectFill

        pipVideoCallViewController = AVPictureInPictureVideoCallViewController()

        // Pretty much just for aspect ratio, normally used for pop-over
        pipVideoCallViewController.preferredContentSize = CGSize(width: 100, height: 150)

        placeholderView = PIPPlaceholderView()
        pipVideoCallViewController.view.addSubview(placeholderView)

        pipVideoCallViewController.view.addSubview(videoView)

        videoView.translatesAutoresizingMaskIntoConstraints = false;

        let constraints = [
            videoView.leadingAnchor.constraint(equalTo: pipVideoCallViewController.view.leadingAnchor),
            videoView.trailingAnchor.constraint(equalTo: pipVideoCallViewController.view.trailingAnchor),
            videoView.topAnchor.constraint(equalTo: pipVideoCallViewController.view.topAnchor),
            videoView.bottomAnchor.constraint(equalTo: pipVideoCallViewController.view.bottomAnchor)
        ]

        NSLayoutConstraint.activate(constraints)

        let pipContentSource = AVPictureInPictureController.ContentSource(
            activeVideoCallSourceView: self,
            contentViewController: pipVideoCallViewController
        )

        pipController = AVPictureInPictureController(contentSource: pipContentSource)
        pipController.canStartPictureInPictureAutomaticallyFromInline = true
        pipController.delegate = self
        //self.backgroundColor = .red
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    func configure(participant: RemoteParticipant) {
        NSLog("[Kevin] We have configure the PictureInPictureSetupView")
        placeholderView.configure(participantName: participant.identity)
        // TODO: KLG Do we want to ensure for camera here
        videoView.videoTrack = participant.videoTracks.first?.videoTrack
        //videoView.alpha = participant.isCameraTrackSwitchedOff || participant.cameraTrack == nil ? 0 : 1
    }
}

extension PictureInPictureSetupView: AVPictureInPictureControllerDelegate {
    func pictureInPictureControllerWillStartPictureInPicture(
        _ pictureInPictureController: AVPictureInPictureController
    ) {
        print("pip controller delegate: will start")
    }

    func pictureInPictureControllerDidStartPictureInPicture(
        _ pictureInPictureController: AVPictureInPictureController
    ) {
        print("pip controller delegate: did start")
    }

    func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        failedToStartPictureInPictureWithError error: Error
    ) {
        print("pip controller delegate: failed to start \(error)")
    }

    func pictureInPictureControllerWillStopPictureInPicture(
        _ pictureInPictureController: AVPictureInPictureController
    ) {
        print("pip controller delegate: will stop")
    }

    func pictureInPictureControllerDidStopPictureInPicture(
        _ pictureInPictureController: AVPictureInPictureController
    ) {
        print("pip controller delegate: did stop")
    }

    func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void
    ) {
        print("pip controller delegate: restore UI")
    }
}

// TODO: Move to the SDK
class VideoTrackStoringSampleBufferVideoView: SampleBufferVideoView {
    var videoTrack: VideoTrack? {
        didSet {
            guard oldValue != videoTrack else { return }

            oldValue?.removeRenderer(self)

            if let videoTrack = videoTrack {
                videoTrack.addRenderer(self)
            }
        }
    }
}
