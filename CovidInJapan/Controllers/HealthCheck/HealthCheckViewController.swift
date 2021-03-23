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
    
    private let scrollView = UIScrollView()
    private let calendar = FSCalendar()
    private let checkLabel = UILabel()
    private let resultButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGroupedBackground
        today = dateFormatter(day: Date())
        
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        scrollView.contentSize = CGSize(width: view.frame.size.width, height: 950)
        view.addSubview(scrollView)
        
        calendar.frame = CGRect(x: 20, y: 10, width: view.frame.size.width - 40, height: 300)
        calendar.appearance.headerTitleColor = colors.bluePurple
        calendar.appearance.weekdayTextColor = colors.bluePurple
        calendar.delegate = self
        calendar.dataSource = self
        scrollView.addSubview(calendar)
        
        checkLabel.text = R.string.settings.healthCheck()
        checkLabel.textColor = colors.white
        checkLabel.frame = CGRect(x: 0, y: 340, width: view.frame.size.width, height: 21)
        checkLabel.backgroundColor = colors.blue
        checkLabel.textAlignment = .center
        checkLabel.center.x = view.center.x
        scrollView.addSubview(checkLabel)
        
        let checkFeverView = createCheckItemView(y: 380)
        scrollView.addSubview(checkFeverView)
        createImage(parentView: checkFeverView, image: R.image.fever())
        createLabel(parentView: checkFeverView, text: R.string.settings.fever())
        createUISwitch(parentView: checkFeverView, action: #selector(switchAction))
        let checkSoreThroatView = createCheckItemView(y: 465)
        scrollView.addSubview(checkSoreThroatView)
        createImage(parentView: checkSoreThroatView, image: R.image.soreThroat())
        createLabel(parentView: checkSoreThroatView, text: R.string.settings.soreThroat())
        createUISwitch(parentView: checkSoreThroatView, action: #selector(switchAction))
        let checkSmellView = createCheckItemView(y: 550)
        scrollView.addSubview(checkSmellView)
        createImage(parentView: checkSmellView, image: R.image.lossOfSenseOfSmell())
        createLabel(parentView: checkSmellView, text: R.string.settings.loseOfSenseOfSmell())
        createUISwitch(parentView: checkSmellView, action: #selector(switchAction))
        let checkTasteView = createCheckItemView(y: 635)
        scrollView.addSubview(checkTasteView)
        createImage(parentView: checkTasteView, image: R.image.lossOfSenseOfTaste())
        createLabel(parentView: checkTasteView, text: R.string.settings.loseOfSenseOfTaste())
        createUISwitch(parentView: checkTasteView, action: #selector(switchAction))
        let checkDullView = createCheckItemView(y: 720)
        scrollView.addSubview(checkDullView)
        createImage(parentView: checkDullView, image: R.image.cold())
        createLabel(parentView: checkDullView, text: R.string.settings.dull())
        createUISwitch(parentView: checkDullView, action: #selector(switchAction))
        
        resultButton.frame = CGRect(x: 0, y: 820, width: 200, height: 40)
        resultButton.center.x = scrollView.center.x
        resultButton.titleLabel?.font = .systemFont(ofSize: 20)
        resultButton.layer.cornerRadius = 5
        resultButton.setTitle(R.string.settings.doneDiagnosis(), for: .normal)
        resultButton.setTitleColor(colors.white, for: .normal)
        resultButton.backgroundColor = colors.blue
        resultButton.addTarget(self, action: #selector(resultButtonAction), for: [.touchUpInside, .touchUpOutside])
        scrollView.addSubview(resultButton)
        
        isDiagnosed()
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
    private func isDiagnosed() {
        if UserDefaults.standard.string(forKey: today) != nil {
            resultButton.isEnabled = false
            resultButton.setTitle(R.string.settings.diagnosed(), for: .normal)
            resultButton.backgroundColor = .white
            resultButton.setTitleColor((.gray), for: .normal)
        }
    }
    @objc private func switchAction(sender: UISwitch) {
        if sender.isOn {
            point += 1
        } else {
            point -= 1
        }
    }
    @objc private func resultButtonAction() {
        let alert = UIAlertController(title: R.string.settings.do_you_want_to_complete_the_diagnosis(), message: R.string.settings.diagnosis_is_up_to_once_a_day(), preferredStyle: .actionSheet)
        let yesAction = UIAlertAction(title: R.string.settings.done(), style: .default, handler: { action in
            var resultTitle = ""
            var resultMessage = ""
            if self.point >= 4 {
                resultTitle = R.string.settings.high()
                resultMessage = R.string.settings.resultMessage_high()
            } else if self.point >= 2 {
                resultTitle = R.string.settings.middle()
                resultMessage = R.string.settings.resultMessage_middle()
            } else {
                resultTitle = R.string.settings.low()
                resultMessage = R.string.settings.resultMessage_low()
            }
            
            let alert = UIAlertController(title: R.string.settings.potentialInfection() + "「\(resultTitle)」", message: resultMessage, preferredStyle: .alert)
            self.present(alert, animated: true, completion: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.dismiss(animated: true, completion: nil)
                }
            })
            // 診断結果をローカル保存
            UserDefaults.standard.set(resultTitle, forKey: self.today)
            self.isDiagnosed()
        })
        let noAction = UIAlertAction(title: R.string.settings.cancel(), style: .destructive, handler: nil)
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
