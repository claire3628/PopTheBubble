//
//  ViewController.swift
//  PopTheBubble
//
//  Created by Claire Chang on 2025/3/11.
//

import UIKit

class ViewController: UIViewController {
    
    private var gameTimer: Timer?
    private var countdownTimer: Timer?
    private var timeRemaining = 30
    private var score = 0
    private var isGameRunning = false
    private var countdown = 3
    
    // 修改 startButton 定義：提示藍色泡泡得1分，紅色泡泡得2分
    private let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("開始遊戲 (藍:1分, 紅:2分)", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let bubbleSize: CGFloat = 120 // 改回原始大小
    private let specialBubbleTag = 999

    // 添加一個數組來追蹤現有泡泡的位置
    private var activeBubbleFrames: [CGRect] = []

    private let timerLabel: UILabel = {
        let label = UILabel()
        label.text = "倒數: 30秒"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.text = "分數: 0"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let countdownLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 150, weight: .bold)
        label.textColor = .systemRed
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        [startButton, timerLabel, scoreLabel, countdownLabel].forEach { view.addSubview($0) }
        
        NSLayoutConstraint.activate([
            timerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            timerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            scoreLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            scoreLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            startButton.widthAnchor.constraint(equalToConstant: 240), // 調整寬度
            startButton.heightAnchor.constraint(equalToConstant: 60), // 調整高度
            
            countdownLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            countdownLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Game Logic
    @objc private func startButtonTapped() {
        startButton.isEnabled = false
        startCountdown()
    }
    
    private func startCountdown() {
        countdown = 3
        timeRemaining = 30
        countdownLabel.isHidden = false
        startButton.isHidden = true  // 隱藏開始按鈕
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            
            if self.countdown == 0 {
                timer.invalidate()
                self.countdownLabel.isHidden = true
                self.countdown = 3
                self.startGame()
            }
            
            self.countdownLabel.text = "\(self.countdown)"
            self.countdown -= 1
        }
    }
    
    private func startGame() {
        isGameRunning = true
        timeRemaining = 30
        score = 0

        updateUI()
        
        activeBubbleFrames.removeAll() // 清空追蹤數組

        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            
            self.timeRemaining -= 1
            self.updateUI()
            
            if self.timeRemaining <= 0 {
                self.endGame()
            }
        }
        
        // 每0.5秒產生一個泡泡
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
            guard let self = self, self.isGameRunning else {
                timer.invalidate()
                return
            }
            self.createBubble()
        }
    }
    
    // 修改 createBubble 方法中的按鈕設置部分
    private func createBubble() {
        // 使用 custom 類型
        let bubble = UIButton(type: .custom)
        bubble.frame = CGRect(x: 0, y: 0, width: bubbleSize, height: bubbleSize)
        
        guard let nonOverlappingPosition = findNonOverlappingPosition() else {
            return
        }
        
        bubble.center = nonOverlappingPosition
        
        // 20% 機率產生特殊泡泡
        if Int.random(in: 1...5) == 1 {
            bubble.backgroundColor = .systemRed
            bubble.tag = specialBubbleTag
        } else {
            bubble.backgroundColor = .systemBlue
            bubble.tag = 0
        }
        
        bubble.layer.cornerRadius = bubbleSize / 2
        bubble.isUserInteractionEnabled = true
        
        // 將泡泡透明度設定為0.5
        bubble.alpha = 0.5

        // 只添加 touchUpInside 事件
        bubble.addTarget(self, action: #selector(bubbleTapped(_:)), for: .touchUpInside)
        
        activeBubbleFrames.append(bubble.frame)
        view.addSubview(bubble)
    }

    // 添加新的輔助方法來找尋不重疊的位置
    private func findNonOverlappingPosition() -> CGPoint? {
        let maxAttempts = 20 // 最大嘗試次數
        let padding: CGFloat = 10 // 泡泡之間的最小間距
        
        for _ in 0..<maxAttempts {
            let maxX = view.bounds.width - bubbleSize
            let maxY = view.bounds.height - bubbleSize
            let randomX = CGFloat.random(in: bubbleSize...maxX)
            let randomY = CGFloat.random(in: bubbleSize...maxY)
            
            let newFrame = CGRect(x: randomX - bubbleSize/2, 
                                y: randomY - bubbleSize/2, 
                                width: bubbleSize + padding, 
                                height: bubbleSize + padding)
            
            // 檢查是否與現有泡泡重疊
            let isOverlapping = activeBubbleFrames.contains { existingFrame in
                return newFrame.intersects(existingFrame.insetBy(dx: -padding, dy: -padding))
            }
            
            if !isOverlapping {
                return CGPoint(x: randomX, y: randomY)
            }
        }
        
        return nil
    }
    
    // 修改 bubbleTapped 方法
    @objc private func bubbleTapped(_ bubble: UIButton) {
        // 防止重複點擊（可選）
        bubble.isUserInteractionEnabled = false
        
        print("泡泡被點擊: tag = \(bubble.tag)")
        
        // 特殊泡泡得雙倍分數
        score += (bubble.tag == specialBubbleTag) ? 2 : 1
        print("當前分數: \(score)")
        
        // 更新 UI
        updateUI()
        
        // 取消現有動畫
        bubble.layer.removeAllAnimations()
        
        // 從追蹤陣列中移除泡泡
        activeBubbleFrames.removeAll { $0 == bubble.frame }
        
        // 執行破裂動畫，然後移除泡泡
        UIView.animate(withDuration: 0.1, animations: {
            bubble.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            bubble.alpha = 0
        }) { _ in
            bubble.removeFromSuperview()
        }
    }
    
    // 修改 updateUI 方法
    private func updateUI() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.timerLabel.text = "倒數: \(self.timeRemaining)秒"
            self.scoreLabel.text = "分數: \(self.score)"
        }
    }
    
    private func endGame() {
        isGameRunning = false
        gameTimer?.invalidate()
        
        activeBubbleFrames.removeAll() // 清空追蹤數組

        // 移除所有泡泡
        view.subviews.forEach { view in
            if view is UIButton && view != startButton {
                view.removeFromSuperview()
            }
        }
        
        // 顯示結果並詢問是否重新開始
        let alert = UIAlertController(
            title: "遊戲結束",
            message: "你的得分是: \(score)",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "重新開始", style: .default) { [weak self] _ in
            self?.startButtonTapped()
        })
        
        // 修改「結束」按鈕動作，按下後重新顯示開始按鈕
        alert.addAction(UIAlertAction(title: "結束", style: .cancel) { [weak self] _ in
            self?.startButton.isHidden = false
            self?.startButton.isEnabled = true
        })
    
        present(alert, animated: true)
    }
}

