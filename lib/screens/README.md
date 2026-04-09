# Flutter Screens Documentation

## Completed Screens (Phase 5)

### 1. Splash Screen (`splash_screen.dart`)

- **Purpose**: Initial loading screen with API health check
- **Features**:
  - Animated logo (scale transition with elasticOut curve)
  - Fade animation for app title
  - Rotating loading indicator
  - API connectivity status indicator
- **Usage**: Set as initial route in main.dart

### 2. Login Screen (`login_screen.dart`)

- **Purpose**: User authentication
- **Features**:
  - Username & password input fields
  - Password visibility toggle
  - Form validation
  - "Forgot password" & "Sign up" links
  - Loading state during login
- **TODO**: Implement actual authentication logic

### 3. Dashboard Screen (`dashboard_screen.dart`)

- **Purpose**: Main hub showing key metrics and quick actions
- **Features**:
  - Welcome greeting
  - 4 stat cards (sales, revenue, low stock, critical stock)
  - Quick action buttons (4 main actions)
  - Recent transactions list
  - Bottom navigation bar
- **Navigation**: Central to app flow, navigates to other screens

### 4. Transaction Screen (`transaction_screen.dart`) ⭐ CRITICAL

- **Purpose**: Input sales data in real-time from shop
- **Features**:
  - Product dropdown selection (auto-fills category)
  - Quantity & price input with auto-calculated total
  - Date picker for transaction date
  - Form validation
  - Transaction history display (in-memory for now)
- **Importance**: This is the PRIMARY data input for ML prediction model
- **Integration**: Saves transactions to local database (future enhancement)

### 5. Product List Screen (`product_list_screen.dart`)

- **Purpose**: View and manage product inventory
- **Features**:
  - Product search functionality
  - Filter by status (semua/tersedia/rendah/kritis)
  - Summary cards (total, available, need stock)
  - Product cards with:
    - Name, category, status badge
    - Price and stock quantity
    - Edit button (placeholder)
- **Status Colors**:
  - Tersedia (Available) = Green
  - Rendah (Low) = Yellow
  - Kritis (Critical) = Red

### 6. Prediction Screen (`prediction_screen.dart`)

- **Purpose**: ML model prediction for stock demand
- **Features**:
  - Input form: Product, Category (auto-fill), Price, Date
  - API integration with MLService
  - Results display showing:
    - Predicted quantity
    - Raw value, estimated total price
    - Model accuracy (R²) and error (MAE)
  - Recommendation card based on prediction
  - Error handling and loading state
- **Integration**: Calls `/prediksi` endpoint from Flask API

### 7. Report Screen (`report_screen.dart`)

- **Purpose**: Sales analytics and business intelligence
- **Features**:
  - Period selector (harian/mingguan/bulanan/tahunan)
  - 4 KPI cards with trend indicators
  - Sales trend chart (placeholder for chart library)
  - Top 4 selling products with progress bars
  - Category breakdown with percentage distribution
  - PDF export button
- **TODO**: Integrate with actual data and chart library (e.g., fl_chart)

## Design System

### Colors (`lib/theme/colors.dart`)

- **Primary**: Brown (#8B7355)
- **Secondary**: Blue, Green, Orange, Red
- **Status**: Success (Green), Warning (Yellow), Error (Red)
- **Neutrals**: Grey scale with light cream background

### Typography (`lib/theme/text_styles.dart`)

- Display, Headline, Title, Body, Label styles
- Multiple size variants (Large, Medium, Small)
- Proper font weights and letter spacing

### Theme (`lib/theme/app_theme.dart`)

- Material 3 design system
- Consistent theming for all components
- Custom input decoration, buttons, cards, navigation

## Navigation Flow

```
Splash Screen
    ↓
Login Screen
    ↓
Dashboard Screen (home)
    ├→ Transaction Screen (primary input)
    ├→ Product List Screen
    ├→ Prediction Screen
    └→ Report Screen
```

## Data Models

- **Product** (`lib/models/product_model.dart`): Inventory items
- **Transaction** (`lib/models/transaction_model.dart`): Sales records
- **PredictionRequest/Result** (`lib/models/prediction_model.dart`): ML API data

## Next Steps

1. **Navigation Setup**:
   - Create app routing/navigation
   - Set Splash as initial route
   - Connect bottom navigation

2. **State Management**:
   - Implement Provider pattern for state
   - Create TransactionProvider, PredictionProvider, etc.

3. **Local Storage**:
   - Add Hive or SQLite for persistence
   - Save transaction history
   - Cache product list

4. **API Integration**:
   - Complete MLService integration in Prediction Screen
   - Handle transactions upload to backend
   - Sync data between app and server

5. **Polish & Testing**:
   - Add unit tests
   - Test API connectivity
   - Performance optimization
   - Error boundary handling

## File Structure

```
lib/
├── screens/
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── dashboard_screen.dart
│   ├── transaction_screen.dart
│   ├── product_list_screen.dart
│   ├── prediction_screen.dart
│   └── report_screen.dart
├── models/
│   ├── product_model.dart
│   ├── transaction_model.dart
│   └── prediction_model.dart
├── theme/
│   ├── colors.dart
│   ├── text_styles.dart
│   └── app_theme.dart
└── services/
    └── ml_service.dart
```
