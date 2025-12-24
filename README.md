# Timely

Native macOS time tracker with keyboard/mouse activity monitoring. Track multiple work sessions daily, monitor productivity, and generate detailed reports - all from your menu bar.

## Features

- 🕐 **Menu Bar Integration** - Quick access to timer controls from your menu bar
- ⏱️ **Multiple Daily Sessions** - Track separate work sessions throughout the day
- 🖱️ **Activity Monitoring** - Automatic keyboard and mouse activity tracking
- 📊 **Productivity Insights** - Detailed analytics and work pattern visualization
- 💾 **CSV Export** - Export time logs for external analysis
- 🔔 **Smart Notifications** - Break reminders and idle time alerts
- 🎯 **Idle Detection** - Automatically detect and track idle periods

## Requirements

- macOS 13.0 (Ventura) or later
- Xcode 15.0 or later (for building from source)

## Installation

### From Source

1. Clone the repository:
```bash
git clone https://github.com/aliyansajid/timely.git
cd timely
```

2. Open `timely.xcodeproj` in Xcode

3. Build and run the project (⌘R)

## Usage

1. Launch Timely - the icon will appear in your menu bar
2. Click the menu bar icon to start/stop timer
3. Open Dashboard to view sessions, analytics, and settings
4. Grant accessibility permissions when prompted (required for activity monitoring)

## Tech Stack

- **Swift** - Native macOS development
- **SwiftUI** - Modern declarative UI framework
- **Combine** - Reactive programming for state management
- **Core Data / CSV** - Data persistence

## Project Structure

```
timely/
├── Models/          # Data models (Session, User, ActivityData)
├── Views/           # SwiftUI views and UI components
├── Services/        # Business logic (ActivityMonitor, TimerManager, DataManager)
├── Resources/       # Assets, data files, and resources
└── Utilities/       # Helper functions and extensions
```

## Privacy

Timely respects your privacy:
- All data is stored locally on your Mac
- No data is sent to external servers
- Activity monitoring can be disabled in settings
- Clear indication when monitoring is active

## Development Status

🚧 **Currently in active development** - Features are being implemented and tested.

## Roadmap

- [ ] Core timer functionality
- [ ] Activity monitoring (keyboard/mouse)
- [ ] CSV data export
- [ ] Dashboard with analytics
- [ ] Settings and preferences
- [ ] Break reminders
- [ ] Reports and charts
- [ ] Session notes and tags

## License

MIT License - feel free to use and modify as needed

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Author

**Aliyan Sajid** - [GitHub](https://github.com/aliyansajid)

---

⏱️ Built with Swift and SwiftUI for macOS
