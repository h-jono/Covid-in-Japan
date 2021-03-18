//
//  ChatViewController.swift
//  CovidInJapan
//
//  Created by 城野 on 2021/03/16.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import FirebaseFirestore

final class ChatViewController: MessagesViewController {
    
    private let colors = Colors()
    private var userId = ""
    private var firestoreData: [FirestoreData] = []
    private var messages: [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Firestore.firestore().collection("Messages").getDocuments(completion: { (document, error) in
            if error != nil {
                print("ChatViewController: Line(\(#line)):error:\(error!)")
            } else {
                guard let document = document else { return }
                for i in 0..<document.count {
                    var storeData = FirestoreData()
                    
                    storeData.date = (document.documents[i].get("date")! as! Timestamp).dateValue()
                    storeData.senderId = document.documents[i].get("senderId")! as? String
                    storeData.text = document.documents[i].get("text")! as? String
                    storeData.userName = document.documents[i].get("userName")! as? String
                    self.firestoreData.append(storeData)
                }
                self.messages = self.getMessages()
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToLastItem()
            }
            
        })
        
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            userId = uuid
        }
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        messagesCollectionView.contentInset.top = 70
        
        let headerView = UIView()
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 70)
        view.addSubview(headerView)
        
        let headerLabel = UILabel()
        headerLabel.font = .systemFont(ofSize: 20, weight: .bold)
        headerLabel.textColor = colors.white
        headerLabel.text = R.string.settings.doctor()
        headerLabel.frame = CGRect(x: 0, y: 20, width: 100, height: 40)
        headerLabel.center.x = view.center.x
        headerLabel.textAlignment = .center
        headerView.addSubview(headerLabel)
        
        let backButton = UIButton(type: .system)
        backButton.frame = CGRect(x: 10, y: 30, width: 20, height: 20)
        backButton.setImage(R.image.back(), for: .normal)
        backButton.tintColor = colors.white
        backButton.titleLabel?.font = .systemFont(ofSize: 20)
        backButton.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        headerView.addSubview(backButton)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 70)
        gradientLayer.colors = [colors.bluePurple.cgColor, colors.blue.cgColor,]
        gradientLayer.startPoint = CGPoint.init(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint.init(x: 1, y: 1)
        headerView.layer.insertSublayer(gradientLayer, at: 0)
        
    }
    @objc private func backButtonAction() {
        dismiss(animated: true, completion: nil)
    }
    
    private func otherSender() -> SenderType {
        return Sender(senderId: "-1", displayName: "OtherName")
    }
    
    private func getMessages() -> [Message] {
        var messageArray: [Message] = []
        for i in 0..<firestoreData.count {
            messageArray.append(createMessage(text: firestoreData[i].text!, date: firestoreData[i].date!, firestoreData[i].senderId!))
        }
        messageArray.sort(by: { a, b -> Bool in
            return a.sentDate < b.sentDate
        })
        return messageArray
    }
    
    // firestoreDataの text, date, senderId を Message 型に変換して返す
    private func createMessage(text: String, date: Date, _ senderId: String) -> Message {
        let attributedText = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.white])
        let sender = (senderId == userId) ? currentSender() : otherSender()
        return Message(attributedText: attributedText, sender: sender as! Sender, messageId: UUID().uuidString, date: date)
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    // メッセージ送信時に発火するメソッド
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        for component in inputBar.inputTextView.components { // 入力情報にアクセス
            guard let text = component as? String else { return }
            let attributedText = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.white])
            let message = Message(attributedText: attributedText, sender: currentSender() as! Sender, messageId: UUID().uuidString, date: Date())
            messages.append(message)
            messagesCollectionView.insertSections([messages.count - 1])
            sendToFirestore(message: text)
            
        }
        inputBar.inputTextView.text = ""
        messagesCollectionView.scrollToLastItem()
        
    }
    
    func sendToFirestore(message: String) {
        Firestore.firestore().collection("Messages").document().setData([
            "date": Date(),
            "senderId": userId,
            "text": message,
            "userName": userId
        ], merge: false) { error in
            guard let error = error else { return }
            print(error)
        }
    }
}

extension ChatViewController: MessagesDataSource, MessageCellDelegate, MessagesLayoutDelegate, MessagesDisplayDelegate {
    // 送信者が自分か、その他の判別のメソッド
    func currentSender() -> SenderType {
        return Sender(senderId: userId, displayName: "MyName")
    }
    // メッセージ表示のメソッド
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    // メッセージ数を返すメソッド
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    // MessagesDisplayDelegate メッセージの送り主を判定し、背景色を設定
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor { //
        return isFromCurrentSender(message: message) ? colors.blueGreen : colors.redOrange
    }
    // MessagesLayoutDelegate メッセージ下部(日付部分)の高さを設定
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
    // MessagesDataSource メッセージ下部に文字(日付)を表示する
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
    // アイコンセット
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) { //
        let avatar: Avatar
        avatar = Avatar(image: isFromCurrentSender(message: message) ? R.image.user() : R.image.doctor())
        avatarView.set(avatar: avatar)
    }
    
}
