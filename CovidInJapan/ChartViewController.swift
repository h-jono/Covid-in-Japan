//
//  ChartViewController.swift
//  CovidInJapan
//
//  Created by 城野 on 2021/03/14.
//

import UIKit
import Charts

final class ChartViewController: UIViewController {
    
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
    private var chartView: HorizontalBarChartView!
    private var pattern = "cases" // セグメント選択肢保存用のプロパティ
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
        backButton.frame = CGRect(x: 10, y: 30, width: 20, height: 20)
        backButton.setImage(UIImage(named: "back"), for: .normal)
        backButton.tintColor = colors.white
        backButton.titleLabel?.font = .systemFont(ofSize: 20)
        backButton.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        view.addSubview(backButton)
        
        let nextButton = UIButton(type: .system)
        nextButton.frame = CGRect(x: view.frame.size.width - 105, y: 25, width: 100, height: 30)
        nextButton.setTitle("円グラフ", for: .normal)
        nextButton.setTitleColor(colors.white, for: .normal)
        nextButton.titleLabel?.font = .systemFont(ofSize: 20)
        nextButton.addTarget(self, action: #selector(goCircle), for: .touchUpInside)
        view.addSubview(nextButton)
        
        segment = UISegmentedControl(items: ["感染者数", "PCR数", "死者数"])
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
        searchBar.placeholder = "都道府県を漢字で入力"
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
        
        prefectureDetailViewLabel(prefectureDetailView, prefectureLabel, 1, 10, text: "東京", size: 30, weight: .ultraLight, color: colors.black)
        prefectureDetailViewLabel(prefectureDetailView, pcrLabel, 0.39, 50, text: "PCR数", size: 15, weight: .bold, color: colors.bluePurple)
        prefectureDetailViewLabel(prefectureDetailView, pcrCountLabel, 0.39, 85, text: "2222222", size: 30, weight: .bold, color: colors.blue)
        prefectureDetailViewLabel(prefectureDetailView, casesLabel, 1, 50, text: "感染者数", size: 15, weight: .bold, color: colors.bluePurple)
        prefectureDetailViewLabel(prefectureDetailView, casesCountLabel, 1, 85, text: "22222", size: 30, weight: .bold, color: colors.blue)
        prefectureDetailViewLabel(prefectureDetailView, deathsLabel, 1.61, 50, text: "死者数", size: 15, weight: .bold, color: colors.bluePurple)
        prefectureDetailViewLabel(prefectureDetailView, deathsCountLabel, 1.61, 85, text: "2222", size: 30, weight: .bold, color: colors.blue)
        
        for i in 0 ..< CovidSingleton.shared.prefecture.count {
            if CovidSingleton.shared.prefecture[i].name_ja == "東京" {
                prefectureLabel.text = CovidSingleton.shared.prefecture[i].name_ja
                pcrCountLabel.text = "\(CovidSingleton.shared.prefecture[i].pcr)"
                casesCountLabel.text = "\(CovidSingleton.shared.prefecture[i].cases)"
                deathsCountLabel.text = "\(CovidSingleton.shared.prefecture[i].deaths)"
            }
        }
        
        chartView = HorizontalBarChartView(frame: CGRect(x: 0, y: 150, width: view.frame.size.width, height: 300))
        chartView.animate(xAxisDuration: 1.0, easingOption: .easeOutCirc)
        chartView.xAxis.labelCount = 10
        chartView.xAxis.labelTextColor = colors.bluePurple
        chartView.doubleTapToZoomEnabled = false
        chartView.delegate = self
        chartView.pinchZoomEnabled = false
        chartView.leftAxis.labelTextColor = colors.bluePurple
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.legend.enabled = false
        chartView.rightAxis.enabled = false
        
        prefectureArray = CovidSingleton.shared.prefecture
        prefectureArray.sort(by: { a, b -> Bool in
            switch pattern {
            case "pcr":
                return a.pcr > b.pcr
            case "deaths":
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
    @objc private func goCircle() {
        performSegue(withIdentifier: "goCircle", sender: nil)
    }
    @objc private func switchAction(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            pattern = "cases"
        case 1:
            pattern = "pcr"
        case 2:
            pattern = "deaths"
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
        var prefectures: [String] = [] // 都道府県名
        for i in 0...9 {
            prefectures += ["\(self.prefectureArray[i].name_ja)"]
        }
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: prefectures)
        
        var entries: [BarChartDataEntry] = [] // データの値
        for i in 0...9 {
            switch pattern {
            case "cases":
                segment.selectedSegmentIndex = 0
                entries += [BarChartDataEntry(x: Double(i), y: Double(self.prefectureArray[i].cases))]
            case "pcr":
                segment.selectedSegmentIndex = 1
                entries += [BarChartDataEntry(x: Double(i), y: Double(prefectureArray[i].pcr))]
            
            case "deaths":
                segment.selectedSegmentIndex = 2
                entries += [BarChartDataEntry(x: Double(i), y: Double(prefectureArray[i].deaths))]
            default:
                break
            }
        }
        
        let set = BarChartDataSet(entries: entries, label: "県別状況")
        set.colors = [colors.blue]
        set.valueTextColor = colors.bluePurple
        set.highlightColor = colors.white
        chartView.data = BarChartData(dataSet: set)
        view.addSubview(chartView)
    }
}

extension ChartViewController: UISearchBarDelegate {
    
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

extension ChartViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        if let dataSet = chartView.data?.dataSets[highlight.dataSetIndex] {
            let index = dataSet.entryIndex(entry: entry)
            prefectureLabel.text = "\(prefectureArray[index].name_ja)"
            pcrCountLabel.text = "\(prefectureArray[index].pcr)"
            casesCountLabel.text = "\(prefectureArray[index].cases)"
            deathsCountLabel.text = "\(prefectureArray[index].deaths)"
        }
    }
}
