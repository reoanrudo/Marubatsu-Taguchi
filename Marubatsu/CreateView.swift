//
//  CreateView.swift
//  Marubatsu
//
//  Created by 田口怜央 on 2025/11/08.
//

import SwiftUI

struct CreateView: View {
    @Binding var quizzesArray: [Quiz] // 回答画面で読み込んだ問題を受け取る
    @State private var questionText = "" // 入力文字を保存
    @State private var selectedAnswer = "O" // 選ばれた答え
    let answers = ["O", "X"] // 選択肢
    
    var body: some View {
        VStack {
            Text("問題文と解答を入力して、追加ボタンを押してください。")
                .foregroundStyle(.gray)
                .padding()
            
            TextField(text: $questionText) {
                Text("問題文を入力してください")
            }
            .padding()
            .textFieldStyle(.roundedBorder)
            
            Picker("解答", selection: $selectedAnswer) {
                ForEach(answers, id: \.self) { answer in
                    Text(answer)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 300)
            .padding()
            
            Button("追加") {
                addQuiz(question: questionText, answer: selectedAnswer)
            }
            .padding()
            
            // 削除ボタン
            Button {
                quizzesArray.removeAll() // 配列を空に
                UserDefaults.standard.removeObject(forKey: "quiz") // 保存されているものを削除
            } label: {
                Text("全削除")
            }
            .foregroundStyle(.red)
            .padding()
        }
    }
    func addQuiz(question: String, answer: String) {
        if question.isEmpty {
            print("問題文が入力されていません")
            return
        }
        
        var savingAnswer = true
        switch answer {
        case "O":
            savingAnswer = true
        case "X":
            savingAnswer = false
        default:
            print("適切な答えが入っていません")
            break
        }
        let newQuiz = Quiz(question: question, answer: savingAnswer)
        
        var array = quizzesArray // 一時的に変数に入れておく
        array.append(newQuiz)    // さっき作った問題を配列に追加
        let storeKey = "quiz"
        
        if let encodedQuizzes = try? JSONEncoder().encode(array) {
            UserDefaults.standard.setValue(encodedQuizzes, forKey: storeKey)
            questionText = "" // 入力欄を空に戻す
            quizzesArray = array // [既存問題 + 新問題]となった配列に更新
        }
        
    }
}

#Preview {
    @Previewable @State var previewQuizzes: [Quiz] = []
    CreateView(quizzesArray: $previewQuizzes)
}
