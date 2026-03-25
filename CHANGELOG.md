# Changelog

All notable changes to PlantCare will be documented in this file.

## [1.0.0] - 2026-03-25

### Added
- Initial release of PlantCare for iOS 17+
- Plant management with photos, species, and location tracking
- Custom watering schedules per plant (every X days)
- Push notification reminders when watering is due
- Quick water logging with tap-to-water functionality
- Overdue indicator with days overdue count
- Plant health log with notes and photos
- Calendar view showing complete watering history
- Home screen widget in small, medium, and large sizes
- Care tips database with 50+ common houseplants including:
  - Watering frequency guidelines
  - Sunlight requirements
  - Soil type recommendations
  - Temperature and humidity preferences
  - Fertilizing schedules
  - Common issues and solutions
  - Expert care tips
- Full dark mode support
- iPad support with optimized layouts
- SwiftUI + MVVM architecture
- SwiftData for local persistence
- Zero external dependencies

### Features
- Indoor/outdoor plant location tracking
- Searchable plant list
- Photo picker integration for plant and health log photos
- Automatic notification scheduling and rescheduling
- Real-time overdue calculations
- Relationship-based data model for efficient queries
- Widget auto-refresh every hour
- Beautiful gradient and material design elements

### Technical
- Minimum iOS version: 17.0
- SwiftUI for all UI components
- SwiftData for data persistence
- UserNotifications for reminders
- WidgetKit for home screen widgets
- PhotosPicker for image selection
- No external dependencies
- MVVM architecture pattern
- App Group for widget data sharing
