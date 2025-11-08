//
//  ContentView.swift
//  Marubatsu
//
//  Created by 田口怜央 on 2025/11/08.
//

import SwiftUI

// MARK: - クイズの構造体

struct Quiz: Identifiable, Codable {
    var id = UUID()       // それぞれの設問を区別するID
    var question: String  // 問題文
    var answer: Bool      // 解答
}

// MARK: - 問題の配列

struct ContentView: View {
    
    // 問題
    let quizeExamples: [Quiz] = [
        Quiz(question: "iPhoneアプリを開発する統合環境はZcodeである", answer: false),
        Quiz(question: "Xcode画面の右側にはユーティリティーズがある", answer: true),
        Quiz(question: "Textは文字列を表示する際に利用する", answer: true)
    ]
    
    @AppStorage("quiz") var quizzesData = Data() // UserDefaultsから問題を読み込む(Data型)
    @State var quizzesArray: [Quiz] = []  // 問題を入れておく配列
    @State var currentQuestionNum: Int = 0 // 今、何問目の数字
    @State var showingAlert = false          // アラートの表示・非表示を管理
    @State var alertTitle = ""               // "正解" か "不正解" の文字を入れる
    
    init() {
        if let decodedQuizzes = try? JSONDecoder().decode([Quiz].self, from: quizzesData) {
            _quizzesArray = State(initialValue: decodedQuizzes)
        }
    }
    
    
    
    // MARK: - body
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                VStack {
                    Text(showQuestion()) // ← ここで問題文を表示
                        .padding()
                        .frame(width: geometry.size.width * 0.85, alignment: .leading) // 横幅を親ビューの横幅の0.85倍、左寄せに
                        .font(.system(size: 25)) // フォントサイズを25に
                        .fontDesign(.rounded)    // フォントを丸みのあるものに
                        .background(.yellow)     // 背景を黄色に
                    
                    Spacer() // 問題文とボタンの間を最大限広げるための余白を配置
                    
                    HStack {
                        Button {
                            checkAnswer(yourAnswer: true) // ◯を押したらtrueを渡す
                        } label: {
                            Text("Ｏ")
                        }
                        .frame(width: geometry.size.width * 0.4, height: geometry.size.width * 0.4) // 横幅と高さを親ビューの横幅の0.4倍を指定
                        .font(.system(size: 100, weight: .bold))  // フォントを大きく太字に
                        .foregroundStyle(.white)                  // 文字色を白
                        .background(.red)                         // 背景を赤
                        Button {
                            checkAnswer(yourAnswer: false) // ×を押したらfalseを渡す
                        } label: {
                            Text("X")
                        }
                        .frame(width: geometry.size.width * 0.4, height:geometry.size.width * 0.4) // 横幅と高さを親ビューの横幅の0.4倍を指定
                        .font(.system(size: 100, weight: .bold))  // フォントを大きく太字に
                        .foregroundStyle(.white)                  // 文字色を白
                        .background(.blue)                         // 背景を青
                    }
                }
                .padding()
                
                
                .navigationTitle("マルバツクイズ") // ナビゲーションバーにタイトル設定
                // 回答時のアラートを追加
                .alert(alertTitle, isPresented: $showingAlert) {
                    Button("OK", role: .cancel) { /* 処理なし */ }
                }
                // 問題作成画面へ遷移するためのボタンを設置
                .toolbar {
                    // 配置する場所を画面最上部のバーの右端に設定
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink {
                            // 遷移先の画面
                            CreateView(quizzesArray: $quizzesArray)
                                .navigationTitle("問題を作ろう")
                        } label: {
                            // 画面に遷移するためのボタンの見た目
                            Image(systemName: "plus")
                                .font(.title)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Func
    
    // 問題を表示する関数
    func showQuestion() -> String {
        var question = "問題がありません!"
        
        // 問題があるかどうかのチェック
        if !quizzesArray.isEmpty{
            let quiz = quizzesArray[currentQuestionNum]
            question = quiz.question
        }
        return question
    }
    // 回答をチェックする関数
    // 正解なら次の問題を表示します
    func checkAnswer(yourAnswer: Bool) {
        if quizzesArray.isEmpty { return } // 問題が無いときは回答チェックしない
        let quiz = quizzesArray[currentQuestionNum]
        let ans = quiz.answer
        
        if yourAnswer == ans { // 正解のとき
            alertTitle = "正解"
            // 現在の問題番号が問題数を超えないように場合分け
            if currentQuestionNum + 1 < quizzesArray.count {
                // currentQuestionNumを1足して次の問題に進む
                currentQuestionNum += 1
            } else {
                // 超えるときは0に戻す
                currentQuestionNum = 0
            }
        } else {
            alertTitle = "不正解"
        }
        showingAlert = true  // アラートを表示
    }
}

// MARK: - Preview

#Preview {
    // Previewでは空のDataを使用
    let _ = UserDefaults.standard.set(Data(), forKey: "quiz")
    return ContentView()
}
