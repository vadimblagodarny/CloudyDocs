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
            if self?.tabBarController?.tabBar.isHidden == true { self?.tabBarController?.tabBar.isHidden = false }
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
    
    func setupViews() {
        view.addSubview(tableView)
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
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
