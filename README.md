# Homebrew Tap for iOS Test Automator

Official Homebrew tap for [iOS Test Automator](https://github.com/mheryerznkanyan/iOS-test-automator).

## Installation

```bash
brew tap mheryerznkanyan/tap
brew install ios-test-automator
```

## What is iOS Test Automator?

AI-powered iOS test automation tool with RAG-enhanced test generation. Write tests in natural language, generate Swift test code automatically, and run them on iOS Simulator.

### Features

- 🤖 Natural language test descriptions
- 🔍 RAG-powered context retrieval
- ✨ Automatic Swift test generation
- ▶️ One-click test execution
- 📹 Video recording of tests
- 🎨 Beautiful web interface

## Quick Start

After installation:

```bash
# Initialize configuration
ios-test-automator init

# Add your Anthropic API key
ios-test-automator config

# Index your iOS app
ios-test-automator rag ingest --app-dir /path/to/your/app

# Start the backend
ios-test-automator server

# Launch the UI (in new terminal)
ios-test-automator ui
```

Then open http://localhost:8501 in your browser.

## Documentation

- [User Guide](https://github.com/mheryerznkanyan/iOS-test-automator/blob/main/USER_GUIDE.md)
- [Quick Reference](https://github.com/mheryerznkanyan/iOS-test-automator/blob/main/QUICK_REFERENCE.md)
- [GitHub Repository](https://github.com/mheryerznkanyan/iOS-test-automator)

## Available Formula

| Formula | Description |
|---------|-------------|
| `ios-test-automator` | AI-powered iOS test automation tool |

## Support

- Report issues: https://github.com/mheryerznkanyan/iOS-test-automator/issues
- Documentation: https://github.com/mheryerznkanyan/iOS-test-automator

## License

MIT
