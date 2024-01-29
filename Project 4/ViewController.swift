//
//  ViewController.swift
//  Project 4
//
//  Created by user250832 on 1/27/24.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var startTimer: UIButton!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    var dateTimer = Timer()
    var timer = Timer()
    var timeLeft = -1
    var playingMusic = false
    var lastAMPM = ""
    var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        startCurrentTime()
        setBackgroundImage()
        timeRemainingLabel.text = ""
        let audioPath = Bundle.main.path(forResource: "song", ofType: "mp3")
        let audioURL = URL(fileURLWithPath: audioPath!)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            audioPlayer?.prepareToPlay()
        } catch {
            print("Error creating audio player")
        }
        
    }
    
    func startCurrentTime() {
        dateTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:#selector(self.currentTime) , userInfo: nil, repeats: true)
    }
    
    @objc  func currentTime() {
        let currentTimeFormatter = DateFormatter()
        currentTimeFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss"
        currentTimeLabel.text  = currentTimeFormatter.string(from: Date())
        setBackgroundImage()
    }
    
    func setBackgroundImage() {
        let backgroundFormatter = DateFormatter()
        backgroundFormatter.dateFormat = "a"
        let currentAMPM = backgroundFormatter.string(from: Date())
        if currentAMPM != lastAMPM {
            lastAMPM = currentAMPM
            if currentAMPM.lowercased() == "am" {
                setTextColor("black")
                backgroundImage.image = UIImage(named: "DayImage")
            } else {
                setTextColor("white")
                backgroundImage.image = UIImage(named: "NightImage")
            }
        }
    }
    
    func setTextColor(_ color: String) {
        let textColor = color == "white" ? UIColor.white : UIColor.black
        let buttonColor = color == "white" ? UIColor.black : UIColor.white
        currentTimeLabel.textColor = textColor
        timeRemainingLabel.textColor = textColor
        startTimer.backgroundColor = textColor
        startTimer.setTitleColor(buttonColor, for: .normal)
        datePicker.setValue(buttonColor, forKey: "textColor")
        datePicker.setValue(textColor, forKey: "backgroundColor")
    }
    
    @IBAction func beginTimer(_ sender: UIButton) {
        timeRemainingLabel.text = ""
        if playingMusic {
            playMusic(false)
        } else {
            timer.invalidate()
            let timeUnformatted = datePicker.date
            let components = Calendar.current.dateComponents([.hour, .minute], from: timeUnformatted)
            timeLeft = (components.hour! * 3600) + (components.minute! * 60)
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(startCountDown), userInfo: nil, repeats: true)
        }
    }
    
    @objc func startCountDown() {
        if timeLeft >= 0 {
            let (hours, minutes, seconds) = convertSeconds(timeLeft)
            timeRemainingLabel.text = "Time Remaining: \(formatTime(hours)):\(formatTime(minutes)):\(formatTime(seconds))"
            timeLeft -= 1
        } else {
            startTimer.setTitle("Stop Music", for: .normal)
            playMusic(true)
            timer.invalidate()
        }
    }
    
    func convertSeconds(_ seconds: Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func formatTime(_ time: Int) -> String {
        return time < 10 ? "0\(time)" : "\(time)"
    }
    
    func playMusic(_ startPlaying: Bool) {
        playingMusic = startPlaying
        if startPlaying {
            audioPlayer!.play()
        } else {
            startTimer.setTitle("Start Timer", for: .normal)
            audioPlayer!.stop()
            audioPlayer!.currentTime = 0
        }
    }
}

