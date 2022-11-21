//
//  ProfileViewController.swift
//  Flicker
//
//  Created by Taehwan Kim on 2022/11/02.
//

import UIKit
import AuthenticationServices
import FirebaseAuth

final class ProfileViewController: EmailViewController {
    // MARK: - Properties: User Data
    private let userName: String? = nil
    private var isArtist: Bool = false
    private let defaults = UserDefaults.standard
    
    // MARK: - Properties: UITable layout
    private let sectionHeaderTitle = ["설정"]
    private let userProfileCell = UIView(frame: .zero)
    private let profileHeader = ProfileHeaderVIew()
    private let tableView = UITableView(frame: CGRectZero, style: .insetGrouped).then {
        $0.isScrollEnabled = false
        $0.showsVerticalScrollIndicator = false
        $0.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileTableViewCell.className)
    }
    
    // MARK: - Funtions: UITable Rendering
    override func viewDidLoad() {
        super.viewDidLoad()
        setFunctionsAndDelegate()
        render()
        setTabGesture()
        print("================================")
        print(defaults.string(forKey: "currentUserEmail"))
        print(defaults.string(forKey: "currentUserName"))
        print(defaults.string(forKey: "currentUserProfileImageUrl"))
        print("================================")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
        tabBarController?.tabBar.isHidden = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func render() {
        view.backgroundColor = .systemGray6
        view.addSubviews(tableView, profileHeader)
        profileHeader.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(tableView.snp.top)
            $0.height.equalTo(180)
        }

        tableView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        tableView.tableHeaderView = profileHeader
    }

    private func setFunctionsAndDelegate() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: - Funtions: Table React
    private func setTabGesture() {
        let tabGesture = UITapGestureRecognizer(target: self, action: #selector(didTapProfileHeader))
        self.profileHeader.addGestureRecognizer(tabGesture)
    }
    
    @objc func didTapProfileHeader() {
        transition(ProfileSettingViewController(), transitionStyle: .push)
    }


    @objc func didToggleSwitch(_ sender: UISwitch) {
        print(sender.isOn)
        if !sender.isOn {
            makeAlert(title: "알림 비활성화", message: "")
        }
    }

    private func goToArtistRegistration() {
        transition(RegisterWelcomeViewController(), transitionStyle: .push)
    }

    private func goToCustomerInquiry() {
        sendReportMail(userName: userName, reportType: .askSomething)
    }

    private func doLogout() {
        makeRequestAlert(title: "로그아웃 하시겠어요?", message: "", okAction: { _ in
            Task {
                [weak self] in
                await LoginManager.shared.fireBaseSignOut()
                DispatchQueue.main.async {
                    self?.goLogin()
                }
            }
        })
    }
    
    private func doSignOut() {
        makeRequestAlert(title: "정말 탈퇴하시겠어요?", message: "회원님의 가입정보는 즉시 삭제되며, 복구가 불가능합니다.", okAction: { _ in
            Task { [weak self] in
                await LoginManager.shared.appleLoginReAuthUser()
                await LoginManager.shared.fireBasewithDraw()
                self?.navigationController?
                    .pushViewController(WithDrawViewController(), animated: true)
            }
        })
    }
}

// MARK: - UITableViewDataSource: Table Cell Text && Indicator
extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.className, for: indexPath) as! ProfileTableViewCell
        let section = ProfileSection(rawValue: indexPath.section)
        if indexPath.item == 0 {
            Task {
                await profileHeader.setupHeaderData(name: defaults.string(forKey: "currentUserName") ?? "", email: defaults.string(forKey: "currentUserEmail") ?? "", imageURL: defaults.string(forKey: "currentUserProfileImageUrl") ?? "")
            }
        }
        // section에 !가 붙었는데 코드가 바뀌지 않는 이상 강제 언래핑을 해도 무관하다고 생각합니다.
        cell.cellTextLabel.text = section!.sectionOptions(isArtist: isArtist)[indexPath.row]
        if section == .settings {
            switch indexPath.row {
            case 0:
                let switchView = UISwitch(frame: .zero)
                switchView.setOn(true, animated: true)
                switchView.addTarget(self, action: #selector(didToggleSwitch), for: .valueChanged)
                cell.accessoryView = switchView
                cell.selectionStyle = .none
            default:
                cell.accessoryType = .disclosureIndicator
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ProfileSection(rawValue: section)!.sectionOptions(isArtist: self.isArtist).count
    }
}

// MARK: - UITableViewDelegate: Table Cell Funtions
extension ProfileViewController: UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return ProfileSection.allCases.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? sectionHeaderTitle.first : nil
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let section = ProfileSection(rawValue: indexPath.section)

        if section == .settings {
            switch indexPath.row {
            case 1:
                isArtist ? print("이 영역에 작가 프로필을 수정 하는 뷰를 만들어 넣어야 합니다.") : goToArtistRegistration()
            case 2:
                goToCustomerInquiry()
            default:
                break
            }
        } else if indexPath.row == 0 {
            switch section {
            case .logout:
                doLogout()
            case .signOut:
                doSignOut()
            default:
                break
            }
        }
    }
}
