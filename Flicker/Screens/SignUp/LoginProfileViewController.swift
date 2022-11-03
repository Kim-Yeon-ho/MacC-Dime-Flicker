//
//  ProfileSettingViewController.swift
//  Flicker
//
//  Created by 김연호 on 2022/11/02.
//

import UIKit

import SnapKit
import Then

class LoginProfileViewController: BaseViewController {

    private var isNickNameWrite = false

    private let profileImageButton = UIButton().then {
        //TODO: 이미지 크기 조정 및 버튼 이벤트로 갤러리 연동 해야함
        $0.tintColor = .black
        $0.layer.cornerRadius = 50
        $0.backgroundColor = .loginGray
        $0.setImage(UIImage(systemName: "camera"), for: .normal)
    }

    private func labelTemplate(labelText: String, textColor: UIColor ,fontStyle: UIFont.TextStyle, fontWeight: UIFont.Weight) -> UILabel {
        let label = UILabel().then {
            $0.text = labelText
            $0.textColor = textColor
            $0.font = .preferredFont(forTextStyle: fontStyle, weight: fontWeight)
        }
        return label
    }

    private lazy var profileLabel1 = labelTemplate(labelText: "자신을 보여줄 수 있는 간단한 프로필 사진을 보여주세요!", textColor: .textSubBlack, fontStyle: .caption1, fontWeight: .medium)

    private lazy var profileLabel2 = labelTemplate(labelText: "프로필 사진은 작가와 모델의 매칭에 도움을 줍니다", textColor: .textSubBlack, fontStyle: .caption1, fontWeight: .medium)

    private lazy var nickNameLabel = labelTemplate(labelText: "닉네임", textColor: .black, fontStyle: .title3, fontWeight: .bold)
    private lazy var isArtistLabel = labelTemplate(labelText: "사진작가로 활동할 예정이신가요?", textColor: .black, fontStyle: .title3, fontWeight: .bold)
    private lazy var afterjoinLabel = labelTemplate(labelText: "가입 후 마이프로필에서 작가등록을 하실 수 있어요!", textColor: .textSubBlack, fontStyle: .caption1, fontWeight: .medium)

    
    private let nickNameField = UITextField().then {
        let attributes = [
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17, weight: .bold)
        ]

        $0.backgroundColor = .loginGray
        $0.attributedPlaceholder = NSAttributedString(string: "닉네임", attributes: attributes)
        $0.autocapitalizationType = .none
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
        $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        $0.leftViewMode = .always
        $0.clipsToBounds = false
        $0.makeShadow(color: .black, opacity: 0.08, offset: CGSize(width: 0, height: 4), radius: 20)
    }

    private let artistTrueButton = UIButton().then {
        $0.setTitle("네", for: .normal)
        $0.backgroundColor = .loginGray
        $0.setTitleColor(.black, for: .normal)
        $0.layer.cornerRadius = 15
    }

    private let artistFalseButton = UIButton().then {
        $0.setTitle("아니오", for: .normal)
        $0.backgroundColor = .loginGray
        $0.setTitleColor(.black, for: .normal)
        $0.layer.cornerRadius = 15
    }

    private let signUpButton = UIButton().then {
        $0.backgroundColor = .loginGray
        $0.setTitleColor(.white, for: .normal)
        $0.setTitle("완료", for: .normal)
        $0.layer.cornerRadius = 15
    }

    private let navigationDivider = UIView().then {
        $0.backgroundColor = .loginGray
    }

    override func render() {
        nickNameField.delegate = self

        signUpButton.isEnabled = false

        view.addSubviews(profileImageButton, profileLabel1, profileLabel2, nickNameLabel, isArtistLabel, afterjoinLabel, nickNameField, artistTrueButton, artistFalseButton, signUpButton, navigationDivider)

        artistTrueButton.addTarget(self, action: #selector(didTapArtistTrueButton), for: .touchUpInside)
        artistFalseButton.addTarget(self, action: #selector(didTapArtistFalseButton), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(didTapSignUpButton), for: .touchUpInside)


        navigationDivider.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(2)
        }
        
        profileImageButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(100)
        }

        profileLabel1.snp.makeConstraints {
            $0.top.equalTo(profileImageButton.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
        }

        profileLabel2.snp.makeConstraints {
            $0.top.equalTo(profileLabel1.snp.bottom).offset(2)
            $0.centerX.equalToSuperview()
        }

        nickNameLabel.snp.makeConstraints {
            $0.top.equalTo(profileLabel2.snp.bottom).offset(45)
            $0.leading.equalToSuperview().inset(20)
        }

        nickNameField.snp.makeConstraints {
            $0.top.equalTo(nickNameLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        isArtistLabel.snp.makeConstraints {
            $0.top.equalTo(nickNameField.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        afterjoinLabel.snp.makeConstraints {
            $0.top.equalTo(isArtistLabel.snp.bottom).offset(5)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        artistTrueButton.snp.makeConstraints {
            $0.top.equalTo(afterjoinLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().inset(20)
            $0.width.equalTo(170)
        }

        artistFalseButton.snp.makeConstraints {
            $0.top.equalTo(afterjoinLabel.snp.bottom).offset(10)
            $0.trailing.equalToSuperview().inset(20)
            $0.width.equalTo(170)
        }

        signUpButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(50)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(50)
        }
    }
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)

        }

        override func setupNavigationBar() {
            super.setupNavigationBar()

            title = "프로필 입력"
        }

    @objc private func didTapArtistTrueButton() {
        artistTrueButton.backgroundColor = .mainPink
        artistTrueButton.setTitleColor(.white, for: .normal)
        artistFalseButton.backgroundColor = .loginGray
        artistFalseButton.setTitleColor(.black, for: .normal)

        if isNickNameWrite {
            signUpButton.isEnabled = true
            signUpButton.backgroundColor = .mainPink
        }
    }

    @objc private func didTapArtistFalseButton() {
        artistTrueButton.backgroundColor = .loginGray
        artistTrueButton.setTitleColor(.black, for: .normal)
        artistFalseButton.backgroundColor = .mainPink
        artistFalseButton.setTitleColor(.white, for: .normal)

        if isNickNameWrite {
            signUpButton.isEnabled = true
            signUpButton.backgroundColor = .mainPink
        }
    }

    @objc private func didTapSignUpButton() {

        let viewController = TabbarViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }

}

extension LoginProfileViewController {
    override func textFieldDidEndEditing(_ textField: UITextField) {
        isNickNameWrite = true
    }
}
