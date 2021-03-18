//
//  CircleChartViewController.swift
//  CovidInJapan
//
//  Created by 城野 on 2021/03/14.
//

import UIKit
import Charts

final class CircleChartViewController: UIViewController {
    
    private let colors = Colors()
    
    private var prefectureLabel = UILabel()
    private var pcrLabel = UILabel()
    private var pcrCountLabel = UILabel()
    private var casesLabel = UILabel()
    private var casesCountLabel = UILabel()
    private var deathsLabel = UILabel()
    private var deathsCountLabel = UILabel()
    private var segment = UISegmentedControl()
    private var prefectureArray: [CovidInfo.Prefecture] = []
    
    private var pattern = R.string.settings.cases() // セグメント選択肢保存用のプロパティ
    private var searchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 60)
        gradientLayer.colors = [colors.bluePurple.cgColor,
                                colors.blue.cgColor,]
        gradientLayer.startPoint = CGPoint.init(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint.init(x: 1, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        let backButton = UIButton(type: .system)
        backButton.frame = CGRect(x: 10, y: 30, width: 100, height: 30)
        backButton.setTitle(R.string.settings.barGraph(), for: .normal)
        backButton.tintColor = colors.white
        backButton.titleLabel?.font = .systemFont(ofSize: 20)
        backButton.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        view.addSubview(backButton)
        
        segment = UISegmentedControl(items: [R.string.settings.infectionNumber(), R.string.settings.pcrNumber(), R.string.settings.deaths()])
        segment.frame = CGRect(x: 10, y: 70, width: view.frame.size.width - 20, height: 20)
        segment.selectedSegmentTintColor = colors.blue
        segment.selectedSegmentIndex = 0
        segment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected) // 選択時
        segment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: colors.bluePurple], for: .normal) // 通常時
        segment.addTarget(self, action: #selector(switchAction), for: .valueChanged)
        view.addSubview(segment)
        
        searchBar = UISearchBar()
        searchBar.frame = CGRect(x: 10, y: 100, width: view.frame.size.width - 20, height: 20)
        searchBar.delegate = self
        searchBar.placeholder = R.string.settings.enter_prefectures_in_kanji()
        searchBar.showsCancelButton = true
        searchBar.tintColor = colors.blue
        view.addSubview(searchBar)
        
        let prefectureDetailView = UIView()
        prefectureDetailView.frame = CGRect(x: 10, y: 480, width: view.frame.size.width - 20, height: 167)
        prefectureDetailView.layer.cornerRadius = 10
        prefectureDetailView.backgroundColor = .white
        prefectureDetailView.layer.shadowColor = colors.black.cgColor
        prefectureDetailView.layer.shadowOffset = CGSize(width: 0, height: 2)
        prefectureDetailView.layer.shadowOpacity = 0.4
        prefectureDetailView.layer.shadowRadius = 10
        view.addSubview(prefectureDetailView)
        
        prefectureDetailViewLabel(prefectureDetailView, prefectureLabel, 1, 10, text: R.string.settings.tokyo(), size: 30, weight: .ultraLight, color: colors.black)
        prefectureDetailViewLabel(prefectureDetailView, pcrLabel, 0.39, 50, text: R.string.settings.pcrNumber(), size: 15, weight: .bold, color: colors.bluePurple)
        prefectureDetailViewLabel(prefectureDetailView, pcrCountLabel, 0.39, 85, text: "", size: 30, weight: .bold, color: colors.blue)
        prefectureDetailViewLabel(prefectureDetailView, casesLabel, 1, 50, text: R.string.settings.infectionNumber(), size: 15, weight: .bold, color: colors.bluePurple)
        prefectureDetailViewLabel(prefectureDetailView, casesCountLabel, 1, 85, text: "", size: 30, weight: .bold, color: colors.blue)
        prefectureDetailViewLabel(prefectureDetailView, deathsLabel, 1.61, 50, text: R.string.settings.deathNumber(), size: 15, weight: .bold, color: colors.bluePurple)
        prefectureDetailViewLabel(prefectureDetailView, deathsCountLabel, 1.61, 85, text: "", size: 30, weight: .bold, color: colors.blue)
        
        for i in 0 ..< CovidSingleton.shared.prefecture.count {
            if CovidSingleton.shared.prefecture[i].name_ja == R.string.settings.tokyo() {
                prefectureLabel.text = CovidSingleton.shared.prefecture[i].name_ja
                pcrCountLabel.text = "\(CovidSingleton.shared.prefecture[i].pcr)"
                casesCountLabel.text = "\(CovidSingleton.shared.prefecture[i].cases)"
                deathsCountLabel.text = "\(CovidSingleton.shared.prefecture[i].deaths)"
            }
        }
        
        prefectureArray = CovidSingleton.shared.prefecture
        prefectureArray.sort(by: { a, b -> Bool in
            switch pattern {
            case R.string.settings.pcr():
                return a.pcr > b.pcr
            case R.string.settings.deaths():
                return a.deaths > b.deaths
            default:
                return a.cases > b.cases
            }
        })
        dataSet() // グラフにデータセット
        
        view.backgroundColor = .systemGroupedBackground
        
        
    }
    @objc private func backButtonAction() {
        dismiss(animated: true, completion: nil)
    }
    @objc private func switchAction(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            pattern = R.string.settings.cases()
        case 1:
            pattern = R.string.settings.pcr()
        case 2:
            pattern = R.string.settings.deaths()
        default:
            break
        }
        loadView()
        viewDidLoad()
    }
    
    private func prefectureDetailViewLabel(_ parentView: UIView, _ label: UILabel, _ x: CGFloat, _ y: CGFloat, text: String, size: CGFloat, weight: UIFont.Weight, color: UIColor) {
        
        label.text = text
        label.textColor = color
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.font = .systemFont(ofSize: size, weight: weight)
        label.frame = CGRect(x: 0, y: y, width: parentView.frame.size.width, height: 50)
        label.center.x = view.center.x * x - 10
        
        parentView.addSubview(label)
    }
    
    private func dataSet() {
        var entries: [PieChartDataEntry] = []
        
        switch pattern {
        case R.string.settings.cases():
            segment.selectedSegmentIndex = 0
            for i in 0...4 {
                entries += [PieChartDataEntry(value: Double(prefectureArray[i].cases), label: prefectureArray[i].name_ja)]
            }
        case R.string.settings.pcr():
            segment.selectedSegmentIndex = 1
            for i in 0...4 {
                entries += [PieChartDataEntry(value: Double(prefectureArray[i].pcr), label: prefectureArray[i].name_ja)]
            }
        case R.string.settings.deaths():
            segment.selectedSegmentIndex = 2
            for i in 0...4 {
                entries += [PieChartDataEntry(value: Double(prefectureArray[i].deaths), label: prefectureArray[i].name_ja)]
            }
        default:
            break
        }
        
        let circleView = PieChartView(frame: CGRect(x: 0, y: 150, width: view.frame.size.width, height: 300))
        circleView.centerText = R.string.settings.top_five()
        circleView.animate(xAxisDuration: 2, easingOption: .easeOutExpo)
        let dataSet = PieChartDataSet(entries: entries)
        dataSet.colors = [colors.blue, colors.blueGreen, colors.yellowGreen, colors.yellowOrange, colors.redOrange]
        dataSet.valueTextColor = colors.white
        dataSet.entryLabelColor = colors.white
        circleView.data = PieChartData(dataSet: dataSet)
        circleView.legend.enabled = false
        view.addSubview(circleView)

    }
}

extension CircleChartViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        if let index = prefectureArray.firstIndex(where: { $0.name_ja == searchBar.text}) {
            prefectureLabel.text = "\(prefectureArray[index].name_ja)"
            pcrCountLabel.text = "\(prefectureArray[index].pcr)"
            casesCountLabel.text = "\(prefectureArray[index].cases)"
            deathsCountLabel.text = "\(prefectureArray[index].deaths)"
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        searchBar.text = ""
    }
}
