//
//  so_tcaThreePanelObservationBetaApp.swift
//  so-tcaThreePanelObservationBeta
//
//  Created by Andreas Seeger on 14.12.2023.
//

import SwiftUI

@main
struct so_tcaThreePanelObservationBetaApp: App {
    var body: some Scene {
        WindowGroup {
            AppView(
              store: Store(
                initialState: AppFeature.State(items: []),
                reducer: {
                  AppFeature()
                }
              )
            )
        }
    }
}

struct Item: Equatable, Identifiable {
  let id: UUID
}

import ComposableArchitecture

@Reducer
struct AppFeature {
  struct State: Equatable {
    var items: [Item]

    @PresentationState var sidepanel: SidepanelFeature.State?
    @PresentationState var list: ListFeature.State?
    @PresentationState var detail: DetailFeature.State?

    init(
      items: [Item],
      list: ListFeature.State? = nil,
      detail: DetailFeature.State? = nil
    ) {
      self.items = items
      self.sidepanel = SidepanelFeature.State(items: items)
      self.list = list
      self.detail = detail
    }
  }

  enum Action: Equatable {
    case sidepanel(PresentationAction<SidepanelFeature.Action>)
    case list(PresentationAction<ListFeature.Action>)
    case detail(PresentationAction<DetailFeature.Action>)
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .sidepanel(.presented(.delegate(.showSampleDataButtonPressed))):
        let items = [
          Item(id: UUID()),
          Item(id: UUID()),
          Item(id: UUID()),
        ]
        state.items = items
        state.list = ListFeature.State(items: items)
        return .none
      case .sidepanel:
        return .none

      case let .list(.presented(.delegate(.didSelectItems(itemId)))):
        if 
          let itemId,
          let item = state.items.first(where: { $0.id == itemId }) {
          state.detail = DetailFeature.State(item: item)
        }
        return .none
      case .list:
        return .none

      case .detail:
        return .none
      }
    }
  }
}

struct AppView: View {
  let store: StoreOf<AppFeature>

  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      NavigationSplitView {
        IfLetStore(
          self.store.scope(
            state: \.$sidepanel, 
            action: AppFeature.Action.sidepanel
          )
        ) { store in
          SidepanelView(store: store)
            .padding()
        }
      } content: {
        Group  {
          IfLetStore(
            self.store.scope(
              state: \.$list,
              action: AppFeature.Action.list
            )
          ) { store in
            ListView(store: store)
          } else: {
            ContentUnavailableView("No data yet", systemImage: "xmark")
          }
        }
        .frame(minWidth: 400)
      } detail: {
        Group {
          IfLetStore(
            self.store.scope(
              state: \.$detail,
              action: AppFeature.Action.detail
            )
          ) { store in
            DetailView(store: store)
          }
        }
        .frame(minWidth: 400)
      }
      .frame(minWidth: 950)
    }
  }
}

#Preview {
  AppView(
    store: Store(
      initialState: AppFeature.State(items: []),
      reducer: {
        AppFeature()
      }
    )
  )
}

@Reducer
struct SidepanelFeature {
  struct State: Equatable {
    var items: [Item]
  }

  enum Action: Equatable {
    case delegate(Delegate)

    enum Delegate: Equatable {
      case showSampleDataButtonPressed
    }
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .delegate:
        return .none
      }
    }
  }
}

struct SidepanelView: View {
  let store: StoreOf<SidepanelFeature>

  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      Form {
        Button("Load Sample Data") {
          viewStore.send(.delegate(.showSampleDataButtonPressed))
        }
        Spacer()
      }
      .frame(minWidth: 150)
      .padding()
    }
  }
}

@Reducer
struct ListFeature {
  struct State: Equatable {
    var items: [Item]
  }

  enum Action: Equatable {
    case delegate(Delegate)

    enum Delegate: Equatable {
      case didSelectItems(Item.ID?)
    }
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .delegate:
        return .none
      }
    }
  }
}

struct ListView: View {
  @State private var selection: Item.ID?
  let store: StoreOf<ListFeature>

  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      List(selection: $selection) {
        ForEach(viewStore.items) { item in
          Text(item.id.uuidString)
        }
        .onChange(of: selection) {
          viewStore.send(.delegate(.didSelectItems(selection)))
        }
      }
    }
  }
}

@Reducer
struct DetailFeature {
  struct State: Equatable {
    let item: Item
  }

  enum Action: Equatable {

  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {

      }
    }
  }
}

struct DetailView: View {
  let store: StoreOf<DetailFeature>

  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      Text(viewStore.item.id.uuidString)
    }
  }
}
