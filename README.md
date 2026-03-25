# PlantCare

A beautiful iOS 17+ plant watering reminder and tracker app to help you keep your plants healthy and thriving.

## Features

- **Plant Management**: Add and manage your plant collection with photos, species info, and custom notes
- **Smart Watering Reminders**: Set custom watering schedules for each plant with push notifications
- **Water Logging**: Quick tap to mark plants as watered with automatic history tracking
- **Overdue Indicators**: Visual alerts showing which plants are overdue for watering
- **Health Log**: Track your plant's health with dated notes and photos
- **Calendar View**: Beautiful calendar showing watering history across all plants
- **Home Screen Widget**: Glanceable widget showing plants needing water today
- **Care Tips Database**: Built-in care guide for 50+ common houseplants
- **Dark Mode**: Full support for light and dark appearances
- **iPad Support**: Optimized for both iPhone and iPad

## Technical Details

- **Platform**: iOS 17.0+
- **Architecture**: SwiftUI + MVVM
- **Data Persistence**: SwiftData
- **Notifications**: UserNotifications framework
- **Widgets**: WidgetKit
- **Dependencies**: None (zero external dependencies)
- **Bundle ID**: com.lopodragon.plantcare
- **Price**: $2.99 USD one-time purchase

## Project Structure

```
PlantCare/
├── Models/
│   ├── Plant.swift
│   ├── WateringLog.swift
│   ├── HealthLog.swift
│   └── CareTip.swift
├── ViewModels/
│   └── PlantViewModel.swift
├── Views/
│   ├── PlantListView.swift
│   ├── PlantDetailView.swift
│   ├── AddPlantView.swift
│   ├── CalendarView.swift
│   ├── CareTipsView.swift
│   └── HealthLogView.swift
├── Utils/
│   └── NotificationManager.swift
├── Data/
│   └── CareTipsData.swift
└── Assets.xcassets

PlantCareWidget/
├── PlantCareWidget.swift
├── PlantWidgetEntry.swift
└── Assets.xcassets
```

## Building the App

1. Open `PlantCare.xcodeproj` in Xcode 15 or later
2. Select your development team in the project settings
3. Build and run on a device or simulator running iOS 17+

## Key Features Implementation

### SwiftData Models
- `Plant`: Main model with relationships to watering and health logs
- `WateringLog`: Tracks each watering event with timestamp
- `HealthLog`: Records plant health observations with optional photos
- `CareTip`: Struct for care guide information

### Notifications
- Automatic scheduling when plants are added or watered
- Smart reminders based on custom watering intervals
- Badge updates and sound alerts

### Widget
- Three size variants (small, medium, large)
- Real-time data from SwiftData
- Shows overdue plants with day counts
- Updates hourly automatically

## Care Tips Database

Includes detailed care information for 50+ plants:
- Watering frequency
- Light requirements
- Soil preferences
- Temperature and humidity needs
- Common issues and solutions
- Expert growing tips

## License

MIT License - See LICENSE file for details

## Version

1.0 - Initial Release

## Support

For issues or feature requests, please contact support or visit the App Store page.
