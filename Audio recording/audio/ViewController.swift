//
//  ViewController.swift
//  audio
//
//  Created by Apple on 04/02/23.
//

import UIKit
import Foundation
import AVFoundation

class ViewController: UIViewController,AVAudioRecorderDelegate,AVAudioPlayerDelegate {
       var recordingSession: AVAudioSession!
       var audioRecorder: AVAudioRecorder!
       var audioPlayer:AVAudioPlayer!
       
    var settings = [String : Int]()
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }
        func setupView() {
            recordingSession = AVAudioSession.sharedInstance()
            do {
                try recordingSession.setCategory(.playAndRecord, mode: .default)
                try recordingSession.setActive(true)
                recordingSession.requestRecordPermission() { [unowned self] allowed in
                    DispatchQueue.main.async {
                        if allowed {
                            self.loadRecordingUI()
                        } else {
                            // failed to record
                        }
                    }
                }
            } catch {
          }
        }
    func startRecording() {
           let audioFilename = getFileURL()
           let settings = [
               AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
               AVSampleRateKey: 12000,
               AVNumberOfChannelsKey: 1,
               AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
           
           do {
               audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
               audioRecorder.delegate = self
               audioRecorder.record()
               
               recordButton.setTitle("Tap to Stop", for: .normal)
               playButton.isEnabled = false
           } catch {
               finishRecording(success: false)
           }
       }
    
       func loadRecordingUI() {
           recordButton.isEnabled = true
           playButton.isEnabled = false
           recordButton.setTitle("Tap to Record", for: .normal)
           recordButton.addTarget(self, action: #selector(recordAudioButtonTapped), for: .touchUpInside)
           view.addSubview(recordButton)
       }
       
       @objc func recordAudioButtonTapped(_ sender: UIButton) {
           if audioRecorder == nil {
               startRecording()
           } else {
               finishRecording(success: true)
           }
       }
       

       
       func finishRecording(success: Bool) {
           audioRecorder.stop()
           audioRecorder = nil
           if success {
               recordButton.setTitle("Tap to Re-record", for: .normal)
           } else {
               recordButton.setTitle("Tap to Record", for: .normal)
               // recording failed :(
           }
           playButton.isEnabled = true
           recordButton.isEnabled = true
       }
       
    @objc func recordTapped() {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func preparePlayer() {
          var error: NSError?
          do {
              audioPlayer = try AVAudioPlayer(contentsOf: getFileURL() as URL)
          } catch let error1 as NSError {
              error = error1
              audioPlayer = nil
          }
          
          if let err = error {
              print("AVAudioPlayer error: \(err.localizedDescription)")
          } else {
              audioPlayer.delegate = self
              audioPlayer.prepareToPlay()
              audioPlayer.volume = 10.0
          }
      }
      

      func getFileURL() -> URL {
          let path = getDocumentsDirectory().appendingPathComponent("recording.m4a")
          return path as URL
      }
      
      //MARK: Delegates
      
      func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
          if !flag {
              finishRecording(success: false)
          }
      }
      
      func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
          print("Error while recording audio \(error!.localizedDescription)")
      }
      
      func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
          recordButton.isEnabled = true
          playButton.setTitle("Play", for: .normal)
      }
      
      func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
          print("Error while playing audio \(error!.localizedDescription)")
      }
    @IBAction func play(_ sender: Any) {
        if ((sender as AnyObject).titleLabel?.text == "Play"){
                   recordButton.isEnabled = false
            (sender as AnyObject).setTitle("Stop", for: .normal)
                   preparePlayer()
                   audioPlayer.play()
               } else {
                   audioPlayer.stop()
                   (sender as AnyObject).setTitle("Play", for: .normal)
               }
    }
    
    @IBAction func pouse(_ sender: Any) {
    }
    
}

