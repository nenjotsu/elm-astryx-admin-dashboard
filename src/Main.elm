module Main exposing (main)

import Browser
import Browser.Navigation as Navigation
import Html exposing (Html, a, button, div, h1, h2, header, input, label, main_, nav, p, span, table, tbody, td, text, th, thead, tr)
import Html.Attributes exposing (attribute, checked, class, disabled, href, id, placeholder, type_, value)
import Html.Events exposing (onCheck, onClick, onInput)
import Url exposing (Url)


type Tab
    = Overview
    | Orders
    | Products
    | Customers
    | Inventory
    | Analytics
    | Settings


type alias Order =
    { id : Int
    , orderNo : String
    , customer : String
    , product : String
    , total : String
    , status : String
    }


type alias Model =
    { key : Navigation.Key
    , activeTab : Tab
    , search : String
    , createModalOpen : Bool
    , customerName : String
    , productName : String
    , priority : Bool
    , orders : List Order
    , nextOrderNumber : Int
    }


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url
    | SearchChanged String
    | OpenCreateModal
    | CloseCreateModal
    | CustomerChanged String
    | ProductChanged String
    | PriorityChanged Bool
    | CreateOrder


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }


init : () -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init _ url key =
    ( { key = key
    , activeTab = tabFromUrl url
    , search = ""
    , createModalOpen = False
    , customerName = ""
    , productName = ""
    , priority = False
    , orders =
        [ { id = 1048, orderNo = "ORD-1048", customer = "Amelia Hart", product = "Chocolate Ganache Cake", total = "$68.00", status = "Preparing" }
        , { id = 1047, orderNo = "ORD-1047", customer = "Noah Smith", product = "French Macaron Box", total = "$34.00", status = "Ready" }
        , { id = 1046, orderNo = "ORD-1046", customer = "Mia Chen", product = "Strawberry Layer Cake", total = "$52.00", status = "Confirmed" }
        , { id = 1045, orderNo = "ORD-1045", customer = "Lucas Reed", product = "Croissant Tray", total = "$44.00", status = "Delivered" }
        , { id = 1044, orderNo = "ORD-1044", customer = "Ava Martinez", product = "Blueberry Cheesecake", total = "$48.00", status = "Confirmed" }
        ]
    , nextOrderNumber = 1049
    }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked request ->
            case request of
                Browser.Internal url ->
                    ( model, Navigation.pushUrl model.key (Url.toString url) )

                Browser.External url ->
                    ( model, Navigation.load url )

        UrlChanged url ->
            ( { model | activeTab = tabFromUrl url }, Cmd.none )

        SearchChanged query ->
            ( { model | search = query }, Cmd.none )

        OpenCreateModal ->
            ( { model | createModalOpen = True }, Cmd.none )

        CloseCreateModal ->
            ( { model
                | createModalOpen = False
                , customerName = ""
                , productName = ""
                , priority = False
            }, Cmd.none )

        CustomerChanged customerName ->
            ( { model | customerName = customerName }, Cmd.none )

        ProductChanged productName ->
            ( { model | productName = productName }, Cmd.none )

        PriorityChanged priority ->
            ( { model | priority = priority }, Cmd.none )

        CreateOrder ->
            if createFormValid model then
                let
                    orderNo =
                        "ORD-" ++ String.fromInt model.nextOrderNumber

                    newOrder =
                        { id = model.nextOrderNumber
                        , orderNo = orderNo
                        , customer = String.trim model.customerName
                        , product = String.trim model.productName
                        , total =
                            if model.priority then
                                "$58.00"
                            else
                                "$48.00"
                        , status =
                            if model.priority then
                                "Priority"
                            else
                                "Confirmed"
                        }
                in
                ( { model
                    | orders = newOrder :: model.orders
                    , nextOrderNumber = model.nextOrderNumber + 1
                    , createModalOpen = False
                    , customerName = ""
                    , productName = ""
                    , priority = False
                    , activeTab = Orders
                }
                , Navigation.pushUrl model.key "/orders"
                )

            else
                ( model, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    { title = tabTitle model.activeTab ++ " | Astryx Bakery Admin"
    , body = [ div [ class "app-shell" ]
        [ topBar
        , div [ class "page-shell" ]
            [ sidebar model
            , main_ [ class "main-content" ]
                [ pageHeader model.activeTab
                , if isWorkspaceTab model.activeTab then tabs model else text ""
                , tabContent model
                ]
            ]
        , if model.createModalOpen then
            createOrderModal model
          else
            text ""
        ] ]
    }


topBar : Html Msg
topBar =
    header [ class "topbar" ]
        [ div [ class "brand" ]
            [ span [ class "brand-mark" ] [ text "A" ]
            , div []
                [ div [ class "brand-name" ] [ text "Astryx Bakery Admin" ]
                , div [ class "brand-subtitle" ] [ text "Elm 0.19.2" ]
                ]
            ]
        , div [ class "topbar-spacer" ] []
        , button [ class "icon-button", attribute "aria-label" "Notifications" ] [ text "◉" ]
        , div [ class "profile" ]
            [ div [ class "avatar" ] [ text "CA" ]
            , div []
                [ div [ class "profile-name" ] [ text "Chef Amanda" ]
                , div [ class "profile-role" ] [ text "Administrator" ]
                ]
            ]
        ]


sidebar : Model -> Html Msg
sidebar model =
    nav [ class "sidebar", attribute "aria-label" "Primary navigation" ]
        [ div [ class "sidebar-section-label" ] [ text "WORKSPACE" ]
        , navButton "Overview" "/" Overview model.activeTab
        , navButton "Orders" "/orders" Orders model.activeTab
        , navButton "Products" "/products" Products model.activeTab
        , div [ class "sidebar-section-label secondary" ] [ text "MANAGE" ]
        , navButton "Customers" "/customers" Customers model.activeTab
        , navButton "Inventory" "/inventory" Inventory model.activeTab
        , navButton "Analytics" "/analytics" Analytics model.activeTab
        , navButton "Settings" "/settings" Settings model.activeTab
        ]


navButton : String -> String -> Tab -> Tab -> Html Msg
navButton labelText path tab current =
    a
        [ class
            (if tab == current then
                "nav-item active"
             else
                "nav-item"
            )
        , href path
        ]
        [ span [ class "nav-dot" ] []
        , text labelText
        ]


pageHeader : Tab -> Html Msg
pageHeader tab =
    div [ class "page-header" ]
        [ div []
            [ h1 [] [ text (tabTitle tab) ]
            , p [] [ text (tabDescription tab) ]
            ]
        , button [ class "primary-button", onClick OpenCreateModal ]
            [ span [] [ text "Create order" ]
            , span [ class "button-plus" ] [ text "+" ]
            ]
        ]


tabs : Model -> Html Msg
tabs model =
    div [ class "tabs", attribute "role" "tablist" ]
        [ tabButton "Overview" Overview model.activeTab
        , tabButton "Orders" Orders model.activeTab
        , tabButton "Products" Products model.activeTab
        ]


tabButton : String -> Tab -> Tab -> Html Msg
tabButton labelText tab current =
    a
        [ class
            (if tab == current then
                "tab active"
             else
                "tab"
            )
        , attribute "role" "tab"
        , attribute "aria-selected"
            (if tab == current then "true" else "false")
        , href (tabPath tab)
        ]
        [ text labelText ]


tabContent : Model -> Html Msg
tabContent model =
    case model.activeTab of
        Overview ->
            overviewView model

        Orders ->
            ordersView model

        Products ->
            productsView

        Customers ->
            customersView

        Inventory ->
            inventoryView

        Analytics ->
            analyticsView

        Settings ->
            settingsView


tabFromUrl : Url -> Tab
tabFromUrl url =
    case url.path of
        "/orders" ->
            Orders

        "/products" ->
            Products

        "/customers" ->
            Customers

        "/inventory" ->
            Inventory

        "/analytics" ->
            Analytics

        "/settings" ->
            Settings

        _ ->
            Overview


tabPath : Tab -> String
tabPath tab =
    case tab of
        Overview ->
            "/"

        Orders ->
            "/orders"

        Products ->
            "/products"

        Customers ->
            "/customers"

        Inventory ->
            "/inventory"

        Analytics ->
            "/analytics"

        Settings ->
            "/settings"


tabTitle : Tab -> String
tabTitle tab =
    case tab of
        Overview ->
            "Bakery operations"

        Orders ->
            "Orders"

        Products ->
            "Products"

        Customers ->
            "Customers"

        Inventory ->
            "Inventory"

        Analytics ->
            "Analytics"

        Settings ->
            "Settings"


tabDescription : Tab -> String
tabDescription tab =
    case tab of
        Overview ->
            "Monitor orders, products, and kitchen activity from one workspace."

        Orders ->
            "Search, review, and manage active bakery orders."

        Products ->
            "Manage the cakes and pastries available to your customers."

        Customers ->
            "Review customer profiles, activity, and lifetime value."

        Inventory ->
            "Track ingredient stock and catch items that need replenishing."

        Analytics ->
            "Understand sales performance and product demand."

        Settings ->
            "Configure your bakery workspace and notification preferences."


isWorkspaceTab : Tab -> Bool
isWorkspaceTab tab =
    tab == Overview || tab == Orders || tab == Products


overviewView : Model -> Html Msg
overviewView model =
    div [ class "overview-layout" ]
        [ div [ class "stats-grid" ]
            [ statCard "Orders today" (String.fromInt (List.length model.orders)) "+12.4%" "positive"
            , statCard "Revenue" "$4,860" "+8.1%" "positive"
            , statCard "Products sold" "184" "+16.2%" "positive"
            , statCard "Kitchen queue" "7" "3 urgent" "warning"
            ]
        , div [ class "panel wide-panel" ]
            [ panelHeader "Recent orders" "Latest bakery activity"
            , orderTable (List.take 5 model.orders)
            ]
        , div [ class "panel" ]
            [ panelHeader "Kitchen status" "Live preparation queue"
            , div [ class "queue-list" ]
                [ queueItem "Chocolate Ganache Cake" "12 min" "Preparing"
                , queueItem "Macaron Box × 2" "8 min" "Finishing"
                , queueItem "Strawberry Layer Cake" "24 min" "Baking"
                ]
            ]
        , div [ class "panel" ]
            [ panelHeader "Today" "Production targets"
            , progressRow "Cakes" 72
            , progressRow "Pastries" 58
            , progressRow "Macarons" 84
            ]
        ]


statCard : String -> String -> String -> String -> Html msg
statCard title value_ detail tone =
    div [ class "stat-card" ]
        [ div [ class "stat-label" ] [ text title ]
        , div [ class "stat-value" ] [ text value_ ]
        , span [ class ("stat-detail " ++ tone) ] [ text detail ]
        ]


ordersView : Model -> Html Msg
ordersView model =
    div [ class "panel" ]
        [ div [ class "orders-toolbar" ]
            [ div []
                [ h2 [] [ text "Orders" ]
                , p [] [ text "Search and review active bakery orders." ]
                ]
            , div [ class "search-field" ]
                [ span [ class "search-icon" ] [ text "⌕" ]
                , input
                    [ type_ "search"
                    , placeholder "Search orders"
                    , value model.search
                    , onInput SearchChanged
                    ]
                    []
                ]
            ]
        , orderTable (filteredOrders model)
        ]


productsView : Html Msg
productsView =
    div [ class "product-grid" ]
        [ productCard "Chocolate Ganache Cake" "Cake" "$68" "18 available" "Popular"
        , productCard "French Macaron Box" "Pastry" "$34" "26 available" "Fresh"
        , productCard "Strawberry Layer Cake" "Cake" "$52" "11 available" "Seasonal"
        , productCard "Butter Croissant Tray" "Pastry" "$44" "8 available" "Classic"
        ]


customersView : Html Msg
customersView =
    div [ class "panel" ]
        [ panelHeader "Customer directory" "Your most recent and returning customers"
        , simpleTable
            [ "Customer", "Email", "Orders", "Lifetime value" ]
            [ [ "Amelia Hart", "amelia@example.com", "12", "$846" ]
            , [ "Noah Smith", "noah@example.com", "8", "$492" ]
            , [ "Mia Chen", "mia@example.com", "6", "$378" ]
            , [ "Lucas Reed", "lucas@example.com", "5", "$314" ]
            , [ "Ava Martinez", "ava@example.com", "4", "$268" ]
            ]
        ]


inventoryView : Html Msg
inventoryView =
    div [ class "overview-layout" ]
        [ div [ class "stats-grid" ]
            [ statCard "Ingredients tracked" "42" "38 in stock" "positive"
            , statCard "Low stock" "4" "Needs attention" "warning"
            , statCard "Deliveries due" "3" "This week" "positive"
            , statCard "Waste rate" "2.4%" "−0.6%" "positive"
            ]
        , div [ class "panel wide-panel" ]
            [ panelHeader "Ingredient stock" "Current quantities across the kitchen"
            , simpleTable
                [ "Ingredient", "Category", "On hand", "Status" ]
                [ [ "Flour", "Baking", "48 kg", "In stock" ]
                , [ "Dark chocolate", "Chocolate", "6 kg", "Low stock" ]
                , [ "Butter", "Dairy", "18 kg", "In stock" ]
                , [ "Fresh strawberries", "Produce", "4 crates", "Reorder soon" ]
                ]
            ]
        ]


analyticsView : Html Msg
analyticsView =
    div [ class "overview-layout" ]
        [ div [ class "stats-grid" ]
            [ statCard "Revenue this month" "$24,680" "+8.1%" "positive"
            , statCard "Average order" "$48.20" "+3.4%" "positive"
            , statCard "Repeat customers" "64%" "+5.2%" "positive"
            , statCard "Orders fulfilled" "512" "+12.4%" "positive"
            ]
        , div [ class "panel" ]
            [ panelHeader "Top products" "By revenue this month"
            , progressRow "Chocolate Ganache Cake" 88
            , progressRow "French Macaron Box" 72
            , progressRow "Strawberry Layer Cake" 61
            ]
        , div [ class "panel" ]
            [ panelHeader "Order channels" "Share of completed orders"
            , progressRow "Online store" 68
            , progressRow "In store" 24
            , progressRow "Phone" 8
            ]
        ]


settingsView : Html Msg
settingsView =
    div [ class "settings-grid" ]
        [ div [ class "panel" ]
            [ panelHeader "Bakery profile" "Details shown across your workspace"
            , div [ class "settings-list" ]
                [ settingRow "Business name" "Astryx Bakery"
                , settingRow "Location" "Manila, Philippines"
                , settingRow "Timezone" "Asia/Manila"
                ]
            ]
        , div [ class "panel" ]
            [ panelHeader "Notifications" "Choose which updates the team receives"
            , div [ class "settings-list" ]
                [ settingRow "New orders" "Enabled"
                , settingRow "Low inventory" "Enabled"
                , settingRow "Weekly summary" "Every Monday"
                ]
            ]
        ]


simpleTable : List String -> List (List String) -> Html msg
simpleTable headings rows =
    div [ class "table-wrap" ]
        [ table [ class "data-table" ]
            [ thead [] [ tr [] (List.map (\heading -> th [] [ text heading ]) headings) ]
            , tbody [] (List.map (\row -> tr [] (List.map (\cell -> td [] [ text cell ]) row)) rows)
            ]
        ]


settingRow : String -> String -> Html msg
settingRow name detail =
    div [ class "setting-row" ]
        [ div [] [ div [ class "queue-name" ] [ text name ], div [ class "queue-status" ] [ text detail ] ]
        , button [ class "ghost-button" ] [ text "Edit" ]
        ]


productCard : String -> String -> String -> String -> String -> Html msg
productCard name category price stock badge =
    div [ class "product-card" ]
        [ div [ class "product-visual" ]
            [ span [] [ text (if category == "Cake" then "🎂" else "🥐") ] ]
        , div [ class "product-badge" ] [ text badge ]
        , h2 [] [ text name ]
        , p [] [ text stock ]
        , div [ class "product-footer" ]
            [ span [ class "product-category" ] [ text category ]
            , span [ class "product-price" ] [ text price ]
            ]
        ]


panelHeader : String -> String -> Html msg
panelHeader title subtitle =
    div [ class "panel-header" ]
        [ div []
            [ h2 [] [ text title ]
            , p [] [ text subtitle ]
            ]
        , button [ class "ghost-button" ] [ text "View all" ]
        ]


orderTable : List Order -> Html Msg
orderTable orders =
    div [ class "table-wrap" ]
        [ table [ class "data-table" ]
            [ thead []
                [ tr []
                    [ th [] [ text "Order" ]
                    , th [] [ text "Customer" ]
                    , th [] [ text "Product" ]
                    , th [] [ text "Total" ]
                    , th [] [ text "Status" ]
                    ]
                ]
            , tbody [] (List.map orderRow orders)
            ]
        ]


orderRow : Order -> Html Msg
orderRow order =
    tr []
        [ td [ class "order-number" ] [ text order.orderNo ]
        , td [] [ text order.customer ]
        , td [] [ text order.product ]
        , td [] [ text order.total ]
        , td [] [ span [ class ("status-pill " ++ statusClass order.status) ] [ text order.status ] ]
        ]


statusClass : String -> String
statusClass status =
    case status of
        "Preparing" ->
            "status-warning"

        "Ready" ->
            "status-info"

        "Confirmed" ->
            "status-success"

        "Delivered" ->
            "status-neutral"

        "Priority" ->
            "status-danger"

        _ ->
            "status-neutral"


filteredOrders : Model -> List Order
filteredOrders model =
    let
        query =
            String.toLower (String.trim model.search)
    in
    if String.isEmpty query then
        model.orders
    else
        List.filter
            (\order ->
                String.contains query (String.toLower order.orderNo)
                    || String.contains query (String.toLower order.customer)
                    || String.contains query (String.toLower order.product)
                    || String.contains query (String.toLower order.status)
            )
            model.orders


queueItem : String -> String -> String -> Html msg
queueItem product eta status =
    div [ class "queue-item" ]
        [ div []
            [ div [ class "queue-name" ] [ text product ]
            , div [ class "queue-status" ] [ text status ]
            ]
        , span [ class "queue-eta" ] [ text eta ]
        ]


progressRow : String -> Int -> Html msg
progressRow labelText percent =
    div [ class "progress-row" ]
        [ div [ class "progress-heading" ]
            [ span [] [ text labelText ]
            , span [] [ text (String.fromInt percent ++ "%") ]
            ]
        , div [ class "progress-track" ]
            [ div
                [ class "progress-fill"
                , attribute "style" ("width:" ++ String.fromInt percent ++ "%")
                ]
                []
            ]
        ]


createOrderModal : Model -> Html Msg
createOrderModal model =
    div [ class "modal-layer" ]
        [ button
            [ class "modal-backdrop"
            , attribute "aria-label" "Close modal"
            , onClick CloseCreateModal
            ]
            []
        , div
            [ class "modal"
            , attribute "role" "dialog"
            , attribute "aria-modal" "true"
            , attribute "aria-labelledby" "create-order-title"
            ]
            [ div [ class "modal-header" ]
                [ div []
                    [ span [ class "eyebrow" ] [ text "NEW ORDER" ]
                    , h2 [ id "create-order-title" ] [ text "Create bakery order" ]
                    ]
                , button [ class "close-button", onClick CloseCreateModal, attribute "aria-label" "Close" ] [ text "×" ]
                ]
            , div [ class "modal-content" ]
                [ textField "customer" "Customer name" "Emma Johnson" model.customerName CustomerChanged
                , textField "product" "Cake or pastry" "Chocolate Ganache Cake" model.productName ProductChanged
                , label [ class "checkbox-row" ]
                    [ input [ type_ "checkbox", checked model.priority, onCheck PriorityChanged ] []
                    , span []
                        [ span [ class "checkbox-title" ] [ text "Priority order" ]
                        , span [ class "checkbox-help" ] [ text "Move this order to the front of the kitchen queue." ]
                        ]
                    ]
                ]
            , div [ class "modal-footer" ]
                [ button [ class "secondary-button", onClick CloseCreateModal ] [ text "Cancel" ]
                , button
                    [ class "primary-button"
                    , disabled (not (createFormValid model))
                    , onClick CreateOrder
                    ]
                    [ text "Create order" ]
                ]
            ]
        ]


textField : String -> String -> String -> String -> (String -> Msg) -> Html Msg
textField inputId labelText placeholderText currentValue toMsg =
    div [ class "field" ]
        [ label [ attribute "for" inputId ] [ text labelText ]
        , input
            [ id inputId
            , type_ "text"
            , placeholder placeholderText
            , value currentValue
            , onInput toMsg
            ]
            []
        ]


createFormValid : Model -> Bool
createFormValid model =
    not (String.isEmpty (String.trim model.customerName))
        && not (String.isEmpty (String.trim model.productName))
