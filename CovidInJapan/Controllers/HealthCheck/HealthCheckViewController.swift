//
//  HealthCheckViewController.swift
//  CovidInJapan
//
//  Created by 城野 on 2021/03/13.
//

import UIKit
import FSCalendar
import CalculateCalendarLogic

final class HealthCheckViewController: UIViewController {
    
    private let colors = Colors()
    private var point = 0
    private var today = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGroupedBackground
        today = dateFormatter(day: Date())
        
        let scrollView = UIScrollView()
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        scrollView.contentSize = CGSize(width: view.frame.size.width, height: 950)
        view.addSubview(scrollView)
        
        let calendar = FSCalendar()
        calendar.frame = CGRect(x: 20, y: 10, width: view.frame.size.width - 40, height: 300)
        calendar.appearance.headerTitleColor = colors.bluePurple
        calendar.appearance.weekdayTextColor = colors.bluePurple
        calendar.delegate = self
        calendar.dataSource = self
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
        createImage(parentView: checkFeverView, image: R.image.fever())
        createLabel(parentView: checkFeverView, text: "37.5度以上の熱がある")
        createUISwitch(parentView: checkFeverView, action: #selector(switchAction))
        let checkSoreThroatView = createCheckItemView(y: 465)
        scrollView.addSubview(checkSoreThroatView)
        createImage(parentView: checkSoreThroatView, image: R.image.soreThroat())
        createLabel(parentView: checkSoreThroatView, text: "喉の痛みがある")
        createUISwitch(parentView: checkSoreThroatView, action: #selector(switchAction))
        let checkSmellView = createCheckItemView(y: 550)
        scrollView.addSubview(checkSmellView)
        createImage(parentView: checkSmellView, image: R.image.lossOfSenseOfSmell())
        createLabel(parentView: checkSmellView, text: "匂いを感じない")
        createUISwitch(parentView: checkSmellView, action: #selector(switchAction))
        let checkTasteView = createCheckItemView(y: 635)
        scrollView.addSubview(checkTasteView)
        createImage(parentView: checkTasteView, image: R.image.lossOfSenseOfTaste())
        createLabel(parentView: checkTasteView, text: "味が薄く感じる")
        createUISwitch(parentView: checkTasteView, action: #selector(switchAction))
        let checkDullView = createCheckItemView(y: 720)
        scrollView.addSubview(checkDullView)
        createImage(parentView: checkDullView, image: R.image.cold())
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
        
        if UserDefaults.standard.string(forKey: today) != nil {
            resultButton.isEnabled = false
            resultButton.setTitle("診断済", for: .normal)
            resultButton.backgroundColor = .white
            resultButton.setTitleColor((.gray), for: .normal)
        }
    }
    
    private func createCheckItemView(y: CGFloat) -> UIView {
        let uiView = UIView()
        uiView.frame = CGRect(x: 20, y: y, width: view.frame.size.width - 40, height: 70)
        uiView.backgroundColor = .white
        uiView.layer.cornerRadius = 20
        uiView.layer.shadowColor = UIColor.black.cgColor
        uiView.layer.shadowOpacity = 0.3
        uiView.layer.shadowOffset = CGSize(width: 0, height: 2)
        return uiView
    }
    
    private func createLabel(parentView: UIView, text: String) {
        let label = UILabel()
        label.text = text
        label.frame = CGRect(x: 60, y: 15, width: 200, height: 40)
        parentView.addSubview(label)
    }
    
    private func createImage(parentView: UIView, image: UIImage?) {
        let imageView = UIImageView()
        imageView.image = image
        imageView.frame = CGRect(x: 10, y: 12, width: 40, height: 40)
        parentView.addSubview(imageView)
    }
    
    private func createUISwitch(parentView: UIView, action: Selector) {
        let uiSwitch = UISwitch()
        uiSwitch.frame = CGRect(x: parentView.frame.size.width - 60, y: 20, width: 50, height: 30)
        uiSwitch.addTarget(self, action: action, for: .valueChanged)
        parentView.addSubview(uiSwitch)
    }
    @objc private func switchAction(sender: UISwitch) {
        if sender.isOn {
            point += 1
        } else {
            point -= 1
        }
    }
    @objc private func resultButtonAction() {
        let alert = UIAlertController(title: "診断を完了しますか？", message: "診断は1日に１回までです。", preferredStyle: .actionSheet)
        let yesAction = UIAlertAction(title: "完了", style: .default, handler: { action in
            var resultTitle = ""
            var resultMessage = ""
            if self.point >= 4 {
                resultTitle = "高"
                resultMessage = "感染している可能性が\n比較的高いです。\nPCR検査を受けましょう。"
            } else if self.point >= 2 {
                resultTitle = "中"
                resultMessage = "感染している可能性が\nあります。\nPCR検査を受けましょう。"
            } else {
                resultTitle = "低"
                resultMessage = "感染している可能性は\n０ではありません。\n外出は控えましょう。"
            }
            
            let alert = UIAlertController(title: "感染している可能性「\(resultTitle)」", message: resultMessage, preferredStyle: .alert)
            self.present(alert, animated: true, completion: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.dismiss(animated: true, completion: nil)
                }
            })
            // 診断結果をローカル保存
            UserDefaults.standard.set(resultTitle, forKey: self.today)
        })
        let noAction = UIAlertAction(title: "キャンセル", style: .destructive, handler: nil)
        alert.addAction(yesAction)
        alert.addAction(noAction)
        present(alert, animated: true, completion: nil)
    }
}

extension HealthCheckViewController: FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
        if let result = UserDefaults.standard.string(forKey: dateFormatter(day: date)) {
            return result
        }
        return ""
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, subtitleDefaultColorFor date: Date) -> UIColor? {
        return .init(red: 0, green: 0, blue: 0, alpha: 0.7)
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        return .clear
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderDefaultColorFor date: Date) -> UIColor? {
        // 本日判定
        if dateFormatter(day: date) == today {
            return colors.bluePurple
        }
        return .clear
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderRadiusFor date: Date) -> CGFloat {
        return 0.5
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        // 土日判定
        if judgeWeekday(date) == 1 {
            return UIColor(red: 150/255, green: 30/255, blue: 0/255, alpha: 0.9)
        } else if judgeWeekday(date) == 7 {
            return UIColor(red: 0/255, green: 30/255, blue: 150/255, alpha: 0.9)
        }
        // 祝日判定
        if judgeHoliday(date) {
            return UIColor(red: 150/255, green: 30/255, blue: 0/255, alpha: 0.9)
        }
        return colors.black
    }
    
    func dateFormatter(day: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: day)
    }
    
    func judgeWeekday(_ date: Date) -> Int {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.component(.weekday, from: date)
    }
    
    func judgeHoliday(_ date: Date) -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let holiday = CalculateCalendarLogic()
        let judgeHoliday = holiday.judgeJapaneseHoliday(year: year, month: month, day: day)
        return judgeHoliday
    }
}
