//
//  ContentView.swift
//  WordScramble
//
//  Created by Vitaliy Novichenko on 04.02.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWord = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingAlert = false
    
    @State private var score = 0
    @State private var lettersCount = 0
    
   
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section {
                        TextField("Enter your word", text: $newWord)
                            .font(.title2.bold())
                            .textInputAutocapitalization(.never)
                            .padding()
                            .border(.primary.shadow(.drop(radius: 20)))
                    }
                    VStack(alignment: .center) {
                        Text("Score: \(score)")
                            .padding(.vertical, 10)
                        Spacer()
                        HStack {
                            Text("Word: \(usedWord.count)")
                            Text("Letters: \(lettersCount)")
                        }
                        .padding()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.white)
                    .frame(height: 100)
                    .background(.secondary)
                    .clipShape(.rect(cornerRadius: 20))
                    .font(.title3.bold())
                    
                    
                    Section {
                        ForEach(usedWord, id: \.self) { word in
                            HStack {
                                Image(systemName: "\(word.count).circle")
                                Text(word)
                            }
                            .accessibilityElement()
      // можно так          .accessibilityLabel("\(word), \(word.count) letters")
                            .accessibilityLabel(word)
                            .accessibilityHint("\(word.count) letters")
                        }
                    }
                }
                
                
                .navigationTitle(rootWord)
                .onSubmit(addNewWord)
                .onAppear(perform: startGame)
                .alert(errorTitle, isPresented: $showingAlert) {
                    Button("OK") { newWord = "" }
                } message: {
                    Text(errorMessage)
                }
                .toolbar {
                    Button("Restart Game", action: startGame)
                        .font(.title2.bold())
                }
            }
        }
    }
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 2 else {
            wordError(title: "Слишком короткое слово", message: "Должно быть более 2х букв")
            return
        }
        guard answer != rootWord else {
            wordError(title: "так делать нельзя", message: "Это начальное слово")
            return
        }
        
        // extra validation to come...
        
        guard isOriginal(word: answer) else {
            wordError(title: "Это слово уже использовалось", message: "Будь оригинальнее")
            return
        }
        guard isPossible(word: answer) else {
            wordError(title: "Это не возможно", message: "Вы не можете написать это слово из этих букв \(rootWord.uppercased())")
            return
        }
        guard isReal(word: answer) else {
            wordError(title: "Это не допустимое слово", message: "Нет такого слова в английском языке")
            return
        }
        
        withAnimation {
            usedWord.insert(answer, at: 0)
        }
        lettersCount += answer.count
        score = usedWord.count + lettersCount
        newWord = ""
    }
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL, encoding: .ascii) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                score = 0
                lettersCount = 0
                usedWord = []
                return
            }
        }
        fatalError("Could not load start.txt from bundle")
    }
    func isOriginal(word: String) -> Bool {
        !usedWord.contains(word)
    }
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        
        let misspeledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspeledRange.location == NSNotFound
    }
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingAlert = true
    }
    
}


#Preview {
    ContentView()
}
