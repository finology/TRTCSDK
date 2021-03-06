//
//  AudioCallMainViewController+UI.swift
//  trtcScenesDemo
//
//  Created by xcoderliu on 1/3/20.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import Foundation
import Toast_Swift

extension AudioCallMainViewController {
    func setupUI() {
        ToastManager.shared.position = .bottom
        view.backgroundColor = .appBackGround
        title = "语音通话"
        setupNoHistoryView()
    }
    
    func setupNoHistoryView() {
        view.addSubview(noHistoryView)
        noHistoryView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
        let newCallBtn = UIButton()
        newCallBtn.setTitle("+", for: .normal)
        newCallBtn.titleLabel?.font = UIFont.systemFont(ofSize: 40)
        newCallBtn.backgroundColor = .appTint
        noHistoryView.addSubview(newCallBtn)
        newCallBtn.layer.cornerRadius = 40
        newCallBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(80)
            make.centerX.equalTo(noHistoryView)
            make.centerY.equalTo(noHistoryView).offset(-40)
        }
        newCallBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let self = self else {return}
            self.showSelectVC()
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposebag)
        
        let newTip = UILabel()
        newTip.textColor = .white
        newTip.font = UIFont.systemFont(ofSize: 14)
        newTip.textAlignment = .center
        newTip.numberOfLines = 2
        newTip.text = """
                        点击上方按钮发起呼叫
                       """
        noHistoryView.addSubview(newTip)
        newTip.snp.makeConstraints { (make) in
            make.leading.equalTo(noHistoryView).offset(32)
            make.trailing.equalTo(noHistoryView).offset(-32)
            make.top.equalTo(newCallBtn.snp.bottom).offset(10)
            make.height.equalTo(42)
        }
        
    }
    
    func showSelectVC() {
        let selectVC = AudioSelectContactViewController()
        navigationController?.pushViewController(selectVC, animated: true)
        selectVC.selectedFinished = { [weak self] users in
            guard let self = self else {return}
            var list:[AudioCallUserModel] = []
            var userIds: [String] = []
            for userModel in users {
                list.append(self.covertUser(user: userModel))
                userIds.append(userModel.userId)
            }
            self.showCallVC(invitedList: list)
            TRTCAudioCall.shared.invite(userIds: userIds)
        }
    }
    
    /// show calling view
    /// - Parameters:
    ///   - invitedList: invitee userlist
    ///   - sponsor: passive call should not be nil,
    ///     otherwise sponsor call this mothed should ignore this parameter
    func showCallVC(invitedList: [AudioCallUserModel], sponsor: AudioCallUserModel? = nil) {
        callVC = AudioCallViewController(sponsor: sponsor)
        callVC?.dismissBlock = {[weak self] in
            guard let self = self else {return}
            self.callVC = nil
        }
        if let vc = callVC {
            vc.modalPresentationStyle = .fullScreen
            vc.resetWithUserList(users: invitedList, isInit: true)
            
            if var topController = UIApplication.shared.keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                if let navigationVC = topController as? UINavigationController {
                    if navigationVC.viewControllers.contains(self) {
                        present(vc, animated: false, completion: nil)
                    } else {
                        navigationVC.popToRootViewController(animated: false)
                        navigationVC.pushViewController(self, animated: false)
                        navigationVC.present(vc, animated: false, completion: nil)
                    }
                } else {
                    topController.present(vc, animated: false, completion: nil)
                }
            }
        }
    }
}
