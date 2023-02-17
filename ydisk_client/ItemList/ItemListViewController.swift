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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        viewModel.invokeAuthSignal.bind { [weak self] signal in
            if signal != nil {
                // MARK: TO-DO: display Alert - "Сессия устарела. Необходима повторная авторизация"
                // MARK: TO-DO: invalidate Token.value & UserDefaults value
                self?.viewModel.openOnboarding()
            }
        }

        viewModel.itemsSignal.bind { [weak self] items in
            self?.dataUI = items
            self?.tableView.reloadData()
        }

        viewModel.openItemSignal.bind { [weak self] item in
            if let item = item {
                self?.openItem(item: item)
            }
        }
        
        setupViews()

        switch viewModel.itemListRole {
        case .recentsViewRole: viewModel.openOnboarding()
        case .allFilesViewRole: viewModel.getDiskList()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if tabBarController?.tabBar.isHidden == true {
            tabBarController?.tabBar.isHidden = false
        }
        
        if !tableView.needsUpdateConstraints() {
            setupConstraints()
        }
        
        setupNavigationTitles()
    }
    
    func setupViews() {
        view.addSubview(tableView)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func setupNavigationTitles() {
        let topTitle = NSString(string: viewModel.diskPath).lastPathComponent.components(separatedBy: "&")[0]
        if topTitle == "disk:" {
            navigationItem.title = "Все Файлы"
        } else {
            navigationItem.title = topTitle.removingPercentEncoding
        }
        
        let backBarButtonItem = UIBarButtonItem()
        let backBarButtonTitle = NSString(string: viewModel.diskPath).lastPathComponent.components(separatedBy: "&")[0]
        
        if backBarButtonTitle == "disk:" {
            backBarButtonItem.title = "Все Файлы"
        } else {
            backBarButtonItem.title = backBarButtonTitle
        }
            
        navigationItem.backBarButtonItem = backBarButtonItem
    }
    
    func openItem(item: DataUI) {
        viewModel.openItem(item: item)
    }
    
    @objc func refresh(refreshControl: UIRefreshControl) {
        viewModel.getDiskList()
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
        cell?.configure(viewModel: item)
        return cell ?? UITableViewCell()
    }
}

extension ItemListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = dataUI[indexPath.row]
        viewModel.openItemSignal.value = item
    }
}
