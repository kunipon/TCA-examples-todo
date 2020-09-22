import ComposableArchitecture
import SwiftUI

struct Todo: Equatable, Identifiable {
    let id: UUID
    var description = ""
    var isComplete = false
}

enum TodoAction: Equatable {
    case checkboxTapped
    case textFieldChanged(String)
}

struct TodoEnvironment {}

let todoReducer = Reducer<Todo, TodoAction, TodoEnvironment> { state, action, environment in
    switch action {
    case .checkboxTapped:
        state.isComplete.toggle()
        return .none
    case .textFieldChanged(let text):
        state.description = text
        return .none
    }
}

//------------------------

struct AppState: Equatable {
    var todos: [Todo] = []
}

enum AppAction {
    case todo(index: Int, action: TodoAction)
}

struct AppEnvironment {}

let appReducer: Reducer<AppState, AppAction, AppEnvironment> = todoReducer.forEach(
  state: \.todos,
  action: /AppAction.todo(index:action:),
  environment: { _ in TodoEnvironment() }
)

struct ContentView: View {
    let store: Store<AppState, AppAction>
    
    var body: some View {
        NavigationView {
            WithViewStore(self.store) { viewStore in
                List {
                    ForEachStore(
                        self.store.scope(state: \.todos, action: AppAction.todo(index:action:)),
                        content: TodoView.init(store:)
                    )
                }
                .navigationBarTitle("Todos")
            }
        }
    }
}

struct TodoView: View {
    let store: Store<Todo, TodoAction>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            HStack {
                Button(action: { viewStore.send(.checkboxTapped) }) {
                    Image(systemName: viewStore.isComplete ? "checkmark.square" : "square")
                }
                .buttonStyle(PlainButtonStyle())
                
                TextField(
                    "Untitled Todo",
                    text: viewStore.binding(
                        get: \.description,
                        send: TodoAction.textFieldChanged
                    )
                )
            }
            .foregroundColor(viewStore.isComplete ? .gray : nil)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            store: Store(
                initialState: AppState(
                    todos: [
                        Todo(id: UUID(), description: "Milk", isComplete: false),
                        Todo(id: UUID(), description: "Eggs", isComplete: false),
                        Todo(id: UUID(), description: "Hand Soap", isComplete: false),
                    ]
                ),
                reducer: appReducer,
                environment: AppEnvironment()
            )
        )
    }
}
