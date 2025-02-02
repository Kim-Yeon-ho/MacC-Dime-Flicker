//
//  RegisterPortfolioViewController.swift
//  Flicker
//
//  Created by KYUBO A. SHIM on 2022/11/02.
//

import UIKit
import PhotosUI
import SnapKit
import Then

    // TODO: (다음 버전에..)
final class RegisterPortfolioViewController: UIViewController {
    
    // MARK: - custom delegate to send Datas
    weak var delegate: RegisterPortfolioDelegate?
    
    // MARK: - view UI components
    private let mainTitleLabel = UILabel().then {
        $0.font = UIFont.preferredFont(forTextStyle: .largeTitle, weight: .bold)
        $0.text = "포트폴리오"
    }
    
    private let subTitleLabel = UILabel().then {
        $0.font = UIFont.preferredFont(forTextStyle: .title3, weight: .bold)
        $0.text = "작가님의 포트폴리오를 제출해주세요!"
    }
    
    // TODO: 검토하겠다는 말은 mvp 에서는 넣지 않고, 넣어도 맨 마지막에 "검토 후 알려드릴게요" 라고 하는게 어떨까요?
    private let bodyTitleLabel = UILabel().then {
        $0.numberOfLines = 2
        $0.textColor = .systemGray
        $0.font = UIFont.preferredFont(forTextStyle: .body, weight: .medium)
        $0.text = "포트폴리오가 따로 없어도 괜찮아요.\n자신있는 사진을 등록해주세요."
    }
    
    // MARK: - portfolio image components
    private var portfolioPhotosFetched: [UIImage] = []
    
    private enum portfolioCellIdentifier: String {
        case images = "portfoilo"
        case addButton = "button"
    }
    
    private let portfolioFlowLayout = UICollectionViewFlowLayout().then {
        let imageWidth = (UIScreen.main.bounds.width - 80)/3
        $0.itemSize = CGSize(width: imageWidth , height: imageWidth)
        $0.minimumLineSpacing = 10
    }
    
    private let portfolioPicker: PHPickerViewController = {
        var photoConfiguration = PHPickerConfiguration()
        photoConfiguration.selectionLimit = 12
        photoConfiguration.filter = .images
        let photoPicker = PHPickerViewController(configuration: photoConfiguration)
        return photoPicker
    }()
    
    private lazy var portfolioCollectionView = UICollectionView(frame: .zero, collectionViewLayout: portfolioFlowLayout).then {
        $0.showsVerticalScrollIndicator = false
        $0.isScrollEnabled = true
    }
    
    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        render()
    }
    
    // MARK: - layout constraints
    private func render() {
        view.addSubviews(mainTitleLabel, subTitleLabel, bodyTitleLabel, portfolioCollectionView)
        
        mainTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().inset(30)
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(mainTitleLabel.snp.bottom).offset(30)
            $0.leading.equalToSuperview().inset(30)
        }
        
        bodyTitleLabel.snp.makeConstraints {
            $0.top.equalTo(subTitleLabel.snp.bottom).offset(5)
            $0.leading.trailing.equalToSuperview().inset(30)
        }
        
        portfolioCollectionView.snp.makeConstraints {
            $0.top.equalTo(bodyTitleLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(30)
            $0.bottom.equalToSuperview()
        }
    }
    
    // MARK: - view configurations
    private func configUI() {
        portfolioPicker.delegate = self
        
        portfolioCollectionView.delegate = self
        portfolioCollectionView.dataSource = self
        portfolioCollectionView.register(RegisterPortfolioImageCell.self, forCellWithReuseIdentifier: portfolioCellIdentifier.images.rawValue)
        portfolioCollectionView.register(RegisterAddPhotosCollectionViewCell.self, forCellWithReuseIdentifier: portfolioCellIdentifier.addButton.rawValue)
    }
}

    // MARK: - PHPickerView delegate
    // TODO: 여기서 이제 가져온 image 를 바로 서버에 보낼 수 있는 그런 형태인지 확인도 해야함, image 를 줄이는 건 confirm VC 에서 하자.
extension RegisterPortfolioViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated: true)
        
        let photoItems = results
            .map { $0.itemProvider }
            .filter { $0.canLoadObject(ofClass: UIImage.self) }
        
        let dispatchGroup = DispatchGroup()
        var temporaryImages = [UIImage]()
        
        for photoItem in photoItems {
            dispatchGroup.enter()

            photoItem.loadObject(ofClass: UIImage.self) { photos, error in
                if let image = photos as? UIImage {
                    temporaryImages.append(image)
                }
                
                if let error = error {
                    print(error)
                }
                
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            if (!temporaryImages.isEmpty) {
                self.portfolioPhotosFetched = temporaryImages
                self.portfolioCollectionView.reloadData()
            }
            
            self.delegate?.photoSelected(photos: temporaryImages)
        }
    }
}

    // MARK: - UICollectionView datasource
extension RegisterPortfolioViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return portfolioPhotosFetched.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row < portfolioPhotosFetched.count {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: portfolioCellIdentifier.images.rawValue, for: indexPath) as? RegisterPortfolioImageCell else { return UICollectionViewCell()}
            cell.photoImage.image = self.portfolioPhotosFetched[indexPath.row]
            self.delegate?.photoSelected(photos: portfolioPhotosFetched)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: portfolioCellIdentifier.addButton.rawValue, for: indexPath) as? RegisterAddPhotosCollectionViewCell else { return UICollectionViewCell()}
            if portfolioPhotosFetched.count != 0 {
                return cell
            }
            return cell
        }
    }
}

    // MARK: - UICollectionView delegate
extension RegisterPortfolioViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == portfolioPhotosFetched.count {
            self.present(portfolioPicker, animated: true)
        }
    }
}

// MARK: - RegisterPortfolio custom delegate protocol
protocol RegisterPortfolioDelegate: AnyObject {
    func photoSelected(photos imagesPicked: [UIImage])
}
