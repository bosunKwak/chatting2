//
//  HomeModel.swift
//  chatting2
//
//  Created by 곽보선 on 2021/07/30.
//

import SwiftUI
import Firebase

class HomeModel: ObservableObject{
    
    @Published var txt = ""
    @Published var msgs : [MsgModel] = []
    @AppStorage("current_user") var user = ""

    let db = Firestore.firestore()
    
    init(){
        readAllMsgs()
    }
    
    // 이부분이 문제!! (onAppear(), alertView() )
    // 처음 시뮬레이터를 돌리게 되면
    // Join화면이 나오게 됨!
    // 채팅을 보내는 사람의 이름을 입력하면 됨 -> user에 저장
    func onAppear(){
        
        if user ==  ""{
            //Join Alert
            UIApplication.shared.windows.first?.rootViewController?.present(alertView(), animated: true)
        }
    }
    
    func alertView()->UIAlertController{
        let alert = UIAlertController(title: "Join Chat", message: "Enter Nick Name", preferredStyle: .alert)
        
        alert.addTextField { (txt) in
            txt.placeholder = "eg Kavsoft"
        }
        
        let join = UIAlertAction(title: "Join", style: .default){ (_) in
            //checking for empty click
            
            let user = alert.textFields![0].text ?? ""
            
            if user != ""{
                self.user = user
                return
            }
            
            
            //repromiting alert view
            UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
            
        }
        alert.addAction(join)
        return alert
    }
    
    //firebase로부터 정보 불러오기
    func readAllMsgs(){
        
            db.collection("Msgs")
                //.whereField("id", isEqualTo: name)
                .order(by: "timeStamp", descending: false).addSnapshotListener { (snap,err) in
                    if err != nil{
                        print(err!.localizedDescription)
                        return
                    }

            
            guard let data = snap else{return}

            data.documentChanges.forEach{(doc) in

                if doc.type == .added{

                    let msg = try! doc.document.data(as: MsgModel.self)!

                    DispatchQueue.main.async {
                        self.msgs.append(msg)
                    }
                }
            }
        }
    }
    
    //firebase에 정보 저장
    func writeMsg(){
        let msg = MsgModel(msg: txt, user: user, timeStamp: Date())
        
        let _ = try! db.collection("Msgs").addDocument(from: msg){ (err) in
            
            if err != nil{
                print(err!.localizedDescription)
                return
            }
        }
        self.txt = ""
    }
}
