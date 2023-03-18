import Foundation
import UIKit
import WebKit

class ItemListViewController: UIViewController {

    var viewModel: ItemListViewModelProtocol!
    private var dataUI: [DataUI] = []

    private lazy var tableView: UITableView = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        let tableView = UITableView()
        tableView.refreshControl = refreshControl
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ItemListCell.self, forCellReuseIdentifier: viewModel.itemListRole.rawValue)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = true
        tableView.keyboardDismissMode = .onDrag
        tableView.rowHeight = 50
        tableView.estimatedRowHeight = 50
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView()
        ai.hidesWhenStopped = true
        ai.translatesAutoresizingMaskIntoConstraints = false
        ai.style = .large
        return ai
    }()
    
    private lazy var offlineLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Offline mode / No cache"
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.overrideUserInterfaceStyle = .light
        tabBarController?.overrideUserInterfaceStyle = .light

        viewModel.invokeAuthSignal.bind { [weak self] signal in
            if signal != nil {
                let alert = UIAlertController(title: "Warning", message: "Сессия устарела. Необходима повторная авторизация", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Close", style: .default))
                self?.present(alert, animated: true)
                UserDefaults.standard.removeObject(forKey: "API.Token")
                Token.value = ""
                self?.viewModel.invokeAuthSignal.value = nil
                self?.viewModel.openOnboarding()
            }
        }

        viewModel.itemsSignal.bind { [weak self] items in
            if (self?.viewModel.offsetCounter)! > 1 {
                self?.dataUI += items
            } else {
                self?.dataUI = items
            }
            self?.tableView.reloadData()
            self?.activityIndicator.stopAnimating()
            if self?.dataUI[0].mime_type == "custom/offline" {
                self?.tableView.allowsSelection = false
                self?.offlineLabel.isHidden = false
            } else {
                self?.tableView.allowsSelection = true
                self?.offlineLabel.isHidden = true
            }
        }

        viewModel.openItemSignal.bind { [weak self] item in
            if let item = item {
                guard item.mime_type != "custom/offline" else { return }
                self?.viewModel.openItem(item: item)
            }
        }
        
        viewModel.alertSignal.bind { [weak self] error in
            if let error = error {
                self?.activityIndicator.stopAnimating()
                guard !State.offlineWarned else { return } // Показать предупреждение отсуствия сети один раз
                let alert = UIAlertController(title: "Warning", message: error, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Close", style: .default, handler: { [weak self] _ in
                    // Устраняем залипание tableView при вызове этого обработчика
                    self?.tableView.refreshControl?.beginRefreshing()
                    self?.tableView.refreshControl?.endRefreshing()
                }))
                self?.viewModel.alertSignal.value = nil
                self?.present(alert, animated: true)
                State.offlineWarned = true // Показали предупреждение
            }
        }
        
        setupViews()
        viewModel.persistentStoreLoad()

        switch viewModel.itemListRole {
        case .recentsViewRole:
            activityIndicator.startAnimating()
            viewModel.openOnboarding()
        case .allFilesViewRole:
            activityIndicator.startAnimating()
            viewModel.getDiskList(offset: 0)
        }

        setupConstraints()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Unhide TabBar after successful onboarding
        if tabBarController?.tabBar.isHidden == true {
            tabBarController?.tabBar.isHidden = false
        }
        
        view.backgroundColor = .white
        view.overrideUserInterfaceStyle = .light
        tabBarController?.overrideUserInterfaceStyle = .light
        setupNavigationTitles()
    }
    
    func setupViews() {
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        view.addSubview(offlineLabel)
        offlineLabel.isHidden = true
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            offlineLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            offlineLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    func setupNavigationTitles() {
        let topTitle = NSString(string: viewModel.diskPath).lastPathComponent.components(separatedBy: "&")[0]
        
        if topTitle == "disk:" {
            navigationItem.title = "Все Файлы"
        } else {
            navigationItem.title = topTitle.removingPercentEncoding
        }
        
        if viewModel.itemListRole == .recentsViewRole { navigationItem.title = "Последние" }
        
        let backBarButtonItem = UIBarButtonItem()
        let backBarButtonTitle = NSString(string: viewModel.diskPath).lastPathComponent.components(separatedBy: "&")[0].removingPercentEncoding
        
        if backBarButtonTitle == "disk:" {
            backBarButtonItem.title = "Все Файлы"
        } else {
            backBarButtonItem.title = backBarButtonTitle
        }
            
        navigationItem.backBarButtonItem = backBarButtonItem
    }
    
    @objc func refresh(refreshControl: UIRefreshControl) {
        viewModel.offsetCounter = 0
        viewModel.getDiskList(offset: 0)
        refreshControl.endRefreshing()
    }
}

extension ItemListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataUI.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.itemListRole.rawValue, for: indexPath) as? ItemListCell
        let item = dataUI[indexPath.row]
        cell?.configure(viewModel: item, network: viewModel.network)
        return cell ?? UITableViewCell()
    }
}

extension ItemListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = dataUI[indexPath.row]
        viewModel.openItemSignal.value = item
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == (dataUI.count - 1) &&
            ((indexPath.row + 1) % 20) == 0 &&
            viewModel.itemListRole == .allFilesViewRole {
            activityIndicator.startAnimating()
            viewModel.getDiskList(offset: viewModel.offsetCounter * 20)
        }
    }
}
