import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authModel: AuthModel
    @State var showLogin = false
    @State var error = false
    
    var body: some View {
        NavigationView {
            VStack {
                if error {
                    Text("An Error Occured, Please Try Again")
                        .foregroundColor(Color.red)
                }
                NavigationLink((authModel.session != nil) ? "Change Account" : "Login", isActive: $showLogin) {
                    WebView(url: URL(string: "https://accounts.veracross.com/cwa/portals/login")!) { cookie in
                        showLogin = false
                        error = false
                        authModel.saveToken(cookie) { _ in
                            error = true
                        }
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle("Login")
                }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthModel())
    }
}
