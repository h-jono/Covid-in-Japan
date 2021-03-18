//
//  ViewController.swift
//  CovidInJapan
//
//  Created by 城野 on 2021/03/13.
//

import UIKit
import PKHUD

final class MainViewController: UIViewController {
    
    private let colors = Colors()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpGradation()
        setUpContent()
        
    }
    
    private func setUpGradation() {
        // グラデーションを扱う
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height / 2)
        gradientLayer.colors = [colors.bluePurple.cgColor, colors.blue.cgColor]
        gradientLayer.startPoint = CGPoint.init(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint.init(x: 1, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
        
    }
    
    private func setUpContent() {
        let contentView = UIView()
        contentView.frame.size = CGSize(width: view.frame.size.width, height: 340)
        contentView.center = CGPoint(x: view.center.x, y: view.center.y)
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 30
        contentView.layer.shadowOffset = CGSize(width: 2, height: 2)
        contentView.layer.shadowColor = UIColor.gray.cgColor
        contentView.layer.shadowOpacity = 0.5
        view.addSubview(contentView)
        
        view.backgroundColor = .systemGray6
        
        let labelFront = UIFont.systemFont(ofSize: 15, weight: .heavy)
        let size = CGSize(width: 150, height: 50)
        let color = colors.bluePurple
        let leftX = view.frame.size.width * 0.33
        let rightX = view.frame.size.width * 0.80
        
        setUpLabel("Covid in Japan", size: CGSize(width: 180, height: 35), centerX: view.center.x - 20, y: -60, font: .systemFont(ofSize: 25, weight: .heavy), color: .white, contentView)
        setUpLabel("PCR数", size: size, centerX: leftX, y: 20, font: labelFront, color: color, contentView)
        setUpLabel("感染者数", size: size, centerX: rightX, y: 20, font: labelFront, color: color, contentView)
        setUpLabel("入院者数", size: size, centerX: leftX, y: 120, font: labelFront, color: color, contentView)
        setUpLabel("重症者数", size: size, centerX: rightX, y: 120, font: labelFront, color: color, contentView)
        setUpLabel("死者数", size: size, centerX: leftX, y:220, font: labelFront, color: color, contentView)
        setUpLabel("退院者数", size: size, centerX: rightX, y: 220, font: labelFront, color: color, contentView)
        
        let height = view.frame.size.height / 2
        setUpButton("健康管理", size: size, y: height + 190, color: colors.blue, parentView: view).addTarget(self, action: #selector(goHealthCheck), for: .touchUpInside)
        setUpButton("県別状況", size: size, y: height + 240, color: colors.blue, parentView: view).addTarget(self, action: #selector(goChart), for: .touchUpInside)
        
        setUpImageButton(R.image.chat(), x: view.frame.size.width - 50).addTarget(self, action: #selector(chatAction), for: .touchUpInside)
        setUpImageButton(R.image.reload(), x: 10).addTarget(self, action: #selector(reloadAction), for: .touchUpInside)
        
        let imageView = UIImageView()
        let image = R.image.virus()
        imageView.image = image
        imageView.frame = CGRect(x: view.frame.size.width, y: -65, width: 50, height: 50)
        contentView.addSubview(imageView)
        UIView.animate(withDuration: 1.5, delay: 0.5, options: [.curveEaseIn], animations: {
            imageView.frame = CGRect(x: self.view.frame.size.width - 100, y: -65, width: 50, height: 50)
            imageView.transform = CGAffineTransform(rotationAngle: -90)
        }, completion: nil)
        
        setUpAPI(parentView: contentView)
    }
    
    private func setUpLabel(_ text: String, size: CGSize, centerX: CGFloat, y: CGFloat, font: UIFont, color: UIColor, _ parentView: UIView) {
        let label = UILabel()
        label.text = text
        label.frame.size = size
        label.center.x = centerX
        label.frame.origin.y = y
        label.font = font
        label.textColor = color
        parentView.addSubview(label)
    }
    
    private func setUpButton(_ title: String, size: CGSize, y: CGFloat, color: UIColor, parentView: UIView) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.frame.size = size
        button.center.x = view.center.x
        let attributedTitle = NSAttributedString(string: title, attributes: [NSAttributedString.Key.kern: 8.0])
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.frame.origin.y = y
        button.setTitleColor(color, for: .normal)
        parentView.addSubview(button)
        
        return button
    }
    
    private func setUpImageButton(_ image: UIImage?, x: CGFloat) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(image, for: .normal)
        button.frame.size = CGSize(width: 30, height: 30)
        button.tintColor = .white
        button.frame.origin = CGPoint(x: x, y: 25)
        view.addSubview(button)
        return button
    }
    @objc private func reloadAction() {
        loadView()
        viewDidLoad()
    }
    @objc private func chatAction() {
        performSegue(withIdentifier: "goChat", sender: nil)
    }
    @objc private func goHealthCheck() {
        performSegue(withIdentifier: "goHealthCheck", sender: nil)
    }
    @objc private func goChart() {
        performSegue(withIdentifier: "goChart", sender: nil)
    }
    
    private func setUpAPI(parentView: UIView) {
        let pcr = UILabel()
        let positive = UILabel()
        let hospitalize = UILabel()
        let severe = UILabel()
        let death = UILabel()
        let discharge = UILabel()
        
        let size = CGSize(width: 200, height: 40)
        let leftX = view.frame.size.width * 0.38
        let rightX = view.frame.size.width * 0.85
        let font = UIFont.systemFont(ofSize: 35, weight: .heavy)
        let color = colors.blue
        
        setUpAPILabel(pcr, size: size, centerX: leftX, y: 60, font: font, color: color, parentView)
        setUpAPILabel(positive, size: size, centerX: rightX, y: 60, font: font, color: color, parentView)
        setUpAPILabel(hospitalize, size: size, centerX: leftX, y: 160, font: font, color: color, parentView)
        setUpAPILabel(severe, size: size, centerX: rightX, y: 160, font: font, color: color, parentView)
        setUpAPILabel(death, size: size, centerX: leftX, y: 260, font: font, color: color, parentView)
        setUpAPILabel(discharge, size: size, centerX: rightX, y: 260, font: font, color: color, parentView)
        
        HUD.show(.progress, onView: view)
        CovidAPI.getTotal(completion: {(result: CovidInfo.Total) -> Void in
            DispatchQueue.main.async {
                pcr.text = "\(result.pcr)"
                positive.text = "\(result.positive)"
                hospitalize.text = "\(result.hospitalize)"
                severe.text = "\(result.severe)"
                death.text = "\(result.death)"
                discharge.text = "\(result.discharge)"
                HUD.hide()
            }
        })
    }
    
    private func setUpAPILabel(_ label: UILabel, size: CGSize, centerX: CGFloat, y: CGFloat, font: UIFont, color: UIColor, _ parentView: UIView) {
        label.frame.size = size
        label.center.x = centerX
        label.frame.origin.y = y
        label.font = font
        label.textColor = color
        parentView.addSubview(label)
    }
}

