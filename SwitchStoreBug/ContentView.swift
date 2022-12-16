import ComposableArchitecture
import SwiftUI

struct Parent: ReducerProtocol {

  enum Tab: Equatable {
    case child
    case other
  }


  struct State: Equatable {
    var number: Int
    var section: SectionState
    var selectedTab: Tab

    var child: Child.State? {
      get {

        guard case .child = selectedTab else { return .none }
        return .init(number: number)
      }
      set {
        guard let newValue else { return }
        number = newValue.number
      }
    }
  }

  enum Action {
    case section(SectionAction)
    case select(Tab)
  }

  enum SectionState: Equatable {
    case child(Child.State)
    case other(Other.State)
  }

  enum SectionAction {
    case child(Child.Action)
    case other(Other.Action)
  }

  var body: some ReducerProtocol<State, Action> {
    Scope(state: \.section, action: /Action.section) {
      EmptyReducer()
        .ifCaseLet(/SectionState.child, action: /SectionAction.child) {
          Child()
        }
        .ifCaseLet(/SectionState.other, action: /SectionAction.other) {
          Other()
        }
    }
    
    Reduce { state , action in
      switch action {
      case .section:
        return .none

      case .select(.child):
        state.selectedTab = .child
        if let child = state.child {
          state.section = .child(child)
        }
        return .none

      case .select(.other):
        state.selectedTab = .other
        state.section = .other(.init(number: 0))
        return .none
      }
    }
  }
}

struct Child: ReducerProtocol {

  struct State: Equatable {
    var number: Int
  }

  enum Action {
    case increment
  }

  var body: some ReducerProtocol<State, Action> {
    Reduce { state , action in
      switch action {
      case .increment:
        state.number += 1
        return .none
      }
    }
  }
}

struct ChildView: View {
  let store: StoreOf<Child>

  var body: some View {
    WithViewStore(store) { viewStore in
      VStack {
        Text("Incrementing this number should increment the child number. Child state is computed property on Parent. 'set' in child does not get called.")
        Text("\(viewStore.number)")
        Button("Increment", action: { viewStore.send(.increment) })
      }
    }
  }
}

struct Other: ReducerProtocol {

  struct State: Equatable {
    var number: Int
  }

  enum Action {
    case increment
  }

  var body: some ReducerProtocol<State, Action> {
    Reduce { state , action in
      switch action {
      case .increment:
        state.number += 1
        return .none
      }
    }
  }
}

struct OtherView: View {
  let store: StoreOf<Other>

  var body: some View {
    WithViewStore(store) { viewStore in
      VStack {
        Text("Please select 'Child' tab")
      }
    }
  }
}

struct ParentView: View {
  let store: StoreOf<Parent>

  var body: some View {
    WithViewStore(store) { viewStore in
      VStack {
        Text("Parent Number: \(viewStore.number)")
        VStack {
          Text("Select Tab")
          HStack {
            Button("Child", action: { viewStore.send(.select(.child)) })
            Button("Other", action: { viewStore.send(.select(.other)) })
          }
        }
        .padding()
        SwitchStore(
          store.scope(
            state: \.section,
            action: Parent.Action.section),
          content: {
            CaseLet(
              state: /Parent.SectionState.child,
              action: Parent.SectionAction.child,
              then: ChildView.init)

            CaseLet(
              state: /Parent.SectionState.other,
              action: Parent.SectionAction.other,
              then: OtherView.init)
          }
        )
        .padding()
      }
    }
  }
}
