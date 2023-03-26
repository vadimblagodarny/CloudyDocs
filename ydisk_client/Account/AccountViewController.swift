import Foundation
import UIKit
import Charts

class AccountViewController: UIViewController {
    var viewModel: AccountViewModelProtocol!
    
    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshView), for: .valueChanged)
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.refreshControl = refreshControl
        sv.addSubview(chart)
        sv.addSubview(publishedButton)
        sv.addSubview(activityIndicator)
        chart.isHidden = true
        return sv
    }()
    
    private lazy var publishedButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 10
        button.setTitle(Text.Account.buttonPublished, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = Resources.Colors.primaryAccentColor
        button.addTarget(self, action: #selector(publishTap), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 30, bottom: 10, right: 30)
        return button
    }()

    private lazy var chart: PieChartView = {
        let chart = PieChartView()
        chart.translatesAutoresizingMaskIntoConstraints = false
        chart.delegate = self
        chart.holeRadiusPercent = 0.2
        chart.drawHoleEnabled = false
        chart.isUserInteractionEnabled = false
        return chart
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView()
        ai.hidesWhenStopped = true
        ai.translatesAutoresizingMaskIntoConstraints = false
        ai.style = .large
        return ai
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        
        viewModel.diskInfoSignal.bind { [weak self] diskInfo in
            if let diskInfo = diskInfo {
                self?.drawChart(diskInfo)
            }
        }
        
        activityIndicator.startAnimating()
        viewModel.getDiskInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.backgroundColor = .white
        view.overrideUserInterfaceStyle = .light
        tabBarController?.overrideUserInterfaceStyle = .light
    }
    
    func setupViews() {
        navigationItem.title = Text.Account.navigationTitleAccount
        view.backgroundColor = .white
        view.overrideUserInterfaceStyle = .light
        tabBarController?.overrideUserInterfaceStyle = .light

        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            chart.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            chart.topAnchor.constraint(equalTo: scrollView.topAnchor),
            chart.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
            chart.heightAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
            publishedButton.centerXAnchor.constraint(equalTo: chart.centerXAnchor),
            publishedButton.bottomAnchor.constraint(equalTo: chart.bottomAnchor, constant: 80),
            activityIndicator.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor)
        ])
    }
    
    func drawChart(_ diskInfo: DiskInfo) {
        let freeSpaceGb = Double(diskInfo.total_space - diskInfo.used_space) / (1024.0 * 1024.0 * 1024.0)
        let usedSpaceGb = Double(diskInfo.used_space) / (1024.0 * 1024.0 * 1024.0)
        
        let set = PieChartDataSet(entries: [
            PieChartDataEntry(value: freeSpaceGb, label: Text.Account.chartGbFree),
            PieChartDataEntry(value: usedSpaceGb, label: Text.Account.chartGbUsed)
        ])
        set.colors = [.gray, Resources.Colors.primaryAccentColor]
        set.label = nil
        let data = PieChartData(dataSet: set)
        chart.data = data
        chart.isHidden = false
        activityIndicator.stopAnimating()
        scrollView.refreshControl?.endRefreshing()
    }
    
    @objc func refreshView() {
        viewModel.getDiskInfo()
    }
    
    @objc func publishTap(sender: UIButton!) {
        viewModel.showPublished()
    }
}

extension AccountViewController: ChartViewDelegate {
    
}
