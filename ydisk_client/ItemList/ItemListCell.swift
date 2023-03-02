import UIKit

class ItemListCell: UITableViewCell {
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = label.font.withSize(15)
        return label
    }()
    
    private lazy var sizeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = label.font.withSize(13)
        label.textColor = UIColor(red: 0.621, green: 0.621, blue: 0.621, alpha: 1)
        label.textAlignment = .right
        return label
    }()
    
    private lazy var createdLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = label.font.withSize(13)
        label.textColor = UIColor(red: 0.621, green: 0.621, blue: 0.621, alpha: 1)
        label.textAlignment = .left
        return label
    }()
    
    private lazy var previewImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 5
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCell() {
        contentView.addSubview(previewImage)
        contentView.addSubview(nameLabel)
        contentView.addSubview(sizeLabel)
        contentView.addSubview(createdLabel)
    }
    
    func configure(viewModel: DataUI, network: NetworkProtocol) {
        let dateFormatterOut = DateFormatter()
        dateFormatterOut.dateFormat = "dd.MM.yy, HH:mm"
        let dateString = dateFormatterOut.string(from: (viewModel.created ?? Date()))
        
        nameLabel.text = viewModel.name
        sizeLabel.text = viewModel.size
        createdLabel.text = dateString
        
        if viewModel.type == "dir" {
            self.previewImage.image = UIImage(systemName: "folder")
            return
        }
        
        previewImage.image = UIImage(data: viewModel.preview ?? Data())        
    }
    
    private func setupConstraints() {
        previewImage.widthAnchor.constraint(equalToConstant: 40).isActive = true
        previewImage.heightAnchor.constraint(equalToConstant: 40).isActive = true
        previewImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        previewImage.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        previewImage.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
        
        nameLabel.leadingAnchor.constraint(equalTo: previewImage.trailingAnchor, constant: 20).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        nameLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor).isActive = true

        createdLabel.leadingAnchor.constraint(equalTo: previewImage.trailingAnchor, constant: 20).isActive = true
        createdLabel.trailingAnchor.constraint(equalTo: sizeLabel.leadingAnchor, constant: -20).isActive = true
        createdLabel.topAnchor.constraint(greaterThanOrEqualTo: topAnchor).isActive = true
        createdLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true

        sizeLabel.leadingAnchor.constraint(equalTo: createdLabel.trailingAnchor, constant: 20).isActive = true
        sizeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        sizeLabel.topAnchor.constraint(greaterThanOrEqualTo: topAnchor).isActive = true
        sizeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        previewImage.image = nil
    }
}
