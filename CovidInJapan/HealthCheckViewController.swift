//
//  HealthCheckViewController.swift
//  CovidInJapan
//
//  Created by 城野 on 2021/03/13.
//

import UIKit
import FSCalendar

class HealthCheckViewController: UIViewController {
    
    let colors = Colors()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGroupedBackground
        
        let scrollView = UIScrollView()
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        scrollView.contentSize = CGSize(width: view.frame.size.width, height: 950)
        view.addSubview(scrollView)
        
        let calendar = FSCalendar()
        calendar.frame = CGRect(x: 20, y: 10, width: view.frame.size.width - 40, height: 300)
        calendar.appearance.headerTitleColor = colors.bluePurple
        calendar.appearance.weekdayTextColor = colors.bluePurple
        scrollView.addSubview(calendar)
        
        let checkLabel = UILabel()
        checkLabel.text = "健康チェック"
        checkLabel.textColor = colors.white
        checkLabel.frame = CGRect(x: 0, y: 340, width: view.frame.size.width, height: 21)
        checkLabel.backgroundColor = colors.blue
        checkLabel.textAlignment = .center
        checkLabel.center.x = view.center.x
        scrollView.addSubview(checkLabel)
        
        let checkFeverView = createCheckItemView(y: 380)
        scrollView.addSubview(checkFeverView)
        createImage(parentView: checkFeverView, imageName: "fever")
        createLabel(parentView: checkFeverView, text: "37.5度以上の熱がある")
        createUISwitch(parentView: checkFeverView, action: #selector(switchAction))
        let checkSoreThroatView = createCheckItemView(y: 465)
        scrollView.addSubview(checkSoreThroatView)
        createImage(parentView: checkSoreThroatView, imageName: "sore-throat")
        createLabel(parentView: checkSoreThroatView, text: "喉の痛みがある")
        createUISwitch(parentView: checkSoreThroatView, action: #selector(switchAction))
        let checkSmellView = createCheckItemView(y: 550)
        scrollView.addSubview(checkSmellView)
        createImage(parentView: checkSmellView, imageName: "loss-of-sense-of-smell")
        createLabel(parentView: checkSmellView, text: "匂いを感じない")
        createUISwitch(parentView: checkSmellView, action: #selector(switchAction))
        let checkTasteView = createCheckItemView(y: 635)
        scrollView.addSubview(checkTasteView)
        createImage(parentView: checkTasteView, imageName: "loss-of-sense-of-taste")
        createLabel(parentView: checkTasteView, text: "味が薄く感じる")
        createUISwitch(parentView: checkTasteView, action: #selector(switchAction))
        let checkDullView = createCheckItemView(y: 720)
        scrollView.addSubview(checkDullView)
        createImage(parentView: checkDullView, imageName: "cold")
        createLabel(parentView: checkDullView, text: "だるさがある")
        createUISwitch(parentView: checkDullView, action: #selector(switchAction))
        
        let resultButton = UIButton(type: .system)
        resultButton.frame = CGRect(x: 0, y: 820, width: 200, height: 40)
        resultButton.center.x = scrollView.center.x
        resultButton.titleLabel?.font = .systemFont(ofSize: 20)
        resultButton.layer.cornerRadius = 5
        resultButton.setTitle("診断完了", for: .normal)
        resultButton.setTitleColor(colors.white, for: .normal)
        resultButton.backgroundColor = colors.blue
        resultButton.addTarget(self, action: #selector(resultButtonAction), for: [.touchUpInside, .touchUpOutside])
        scrollView.addSubview(resultButton)
    }
    
    func createCheckItemView(y: CGFloat) -> UIView {
        let uiView = UIView()
        uiView.frame = CGRect(x: 20, y: y, width: view.frame.size.width - 40, height: 70)
        uiView.backgroundColor = .white
        uiView.layer.cornerRadius = 20
        uiView.layer.shadowColor = UIColor.black.cgColor
        uiView.layer.shadowOpacity = 0.3
        uiView.layer.shadowOffset = CGSize(width: 0, height: 2)
        return uiView
    }
    
    func createLabel(parentView: UIView, text: String) {
        let label = UILabel()
        label.text = text
        label.frame = CGRect(x: 60, y: 15, width: 200, height: 40)
        parentView.addSubview(label)
    }
    
    func createImage(parentView: UIView, imageName: String) {
        let imageView = UIImageView()
        imageView.image = UIImage(named: imageName)
        imageView.frame = CGRect(x: 10, y: 12, width: 40, height: 40)
        parentView.addSubview(imageView)
    }
    
    func createUISwitch(parentView: UIView, action: Selector) {
        let uiSwitch = UISwitch()
        uiSwitch.frame = CGRect(x: parentView.frame.size.width - 60, y: 20, width: 50, height: 30)
        uiSwitch.addTarget(self, action: action, for: .valueChanged)
        parentView.addSubview(uiSwitch)
    }
    @objc func switchAction(sender: UISwitch) {
        if sender.isOn {
            print("on")
        } else {
            print("off")
        }
    }
    @objc func resultButtonAction() {
        print("resultButtonTapped")
    }


}
