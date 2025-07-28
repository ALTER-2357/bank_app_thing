//
//  .swift
//  bank_app_thing
//
//  Created by lewis mills on 09/07/2025.
//


      // Top Bar
                HStack {
                    Text("transfers")
                        .font(.largeTitle.bold())
                        .foregroundColor(.primary)
                    Spacer()
                    Button(action: {
                        // Action for adding payee (to be implemented)
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.blue)
                    }
                    .accessibilityLabel("Add payee")
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 10)