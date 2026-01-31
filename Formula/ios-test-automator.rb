# Homebrew Formula for iOS Test Automator
class IosTestAutomator < Formula
  include Language::Python::Virtualenv

  desc "AI-powered iOS test automation tool with RAG-enhanced test generation"
  homepage "https://github.com/mheryerznkanyan/iOS-test-automator"
  url "https://github.com/mheryerznkanyan/iOS-test-automator/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "WILL_BE_REPLACED_AFTER_RELEASE"
  license "MIT"
  head "https://github.com/mheryerznkanyan/iOS-test-automator.git", branch: "main"

  depends_on "python@3.11"
  depends_on :macos
  depends_on xcode: ["15.0", :build]

  def install
    # Create virtualenv and install dependencies from requirements.txt
    venv = virtualenv_create(libexec, "python3.11")

    # Install Python dependencies for all components
    system libexec/"bin/pip", "install", "-r", "python-backend/requirements.txt"
    system libexec/"bin/pip", "install", "-r", "python-rag/requirements.txt"
    system libexec/"bin/pip", "install", "-r", "streamlit-ui/requirements.txt"

    # Install the application
    libexec.install Dir["*"]

    # Create CLI wrapper script
    (bin/"ios-test-automator").write <<~EOS
      #!/bin/bash
      export IOS_TEST_AUTOMATOR_HOME="#{libexec}"
      export PYTHONPATH="#{libexec}:$PYTHONPATH"
      export PATH="#{libexec}/bin:$PATH"

      case "$1" in
        server|backend)
          cd "#{libexec}/python-backend" && "#{libexec}/bin/python" main.py "${@:2}"
          ;;
        ui|streamlit)
          cd "#{libexec}/streamlit-ui" && "#{libexec}/bin/streamlit" run app.py "${@:2}"
          ;;
        rag)
          cd "#{libexec}/python-rag" && "#{libexec}/bin/python" ios_rag_mvp.py "${@:2}"
          ;;
        init)
          "#{bin}/ios-test-automator-init"
          ;;
        status|health)
          echo "🔍 Checking system status..."
          echo ""
          if curl -s http://localhost:8000/health > /dev/null 2>&1; then
            echo "✅ Backend is running (http://localhost:8000)"
          else
            echo "❌ Backend is not running"
          fi
          if curl -s http://localhost:8501 > /dev/null 2>&1; then
            echo "✅ UI is running (http://localhost:8501)"
          else
            echo "❌ UI is not running"
          fi
          ;;
        config|configure)
          ${EDITOR:-nano} "$HOME/.ios-test-automator/.env"
          ;;
        version|--version|-v)
          echo "iOS Test Automator v#{version}"
          ;;
        help|--help|-h|"")
          echo "iOS Test Automator v#{version}"
          echo ""
          echo "AI-powered iOS test automation with RAG-enhanced test generation"
          echo ""
          echo "Usage: ios-test-automator <command> [options]"
          echo ""
          echo "Commands:"
          echo "  server              Start the FastAPI backend server"
          echo "  ui                  Launch the Streamlit web interface"
          echo "  rag <subcommand>    Manage RAG vector store"
          echo "  init                Initialize configuration and directories"
          echo "  status              Check system health and status"
          echo "  config              Edit configuration file"
          echo "  version             Show version information"
          echo "  help                Show this help message"
          echo ""
          echo "Examples:"
          echo "  ios-test-automator init"
          echo "  ios-test-automator rag ingest --app-dir ~/Projects/MyApp/Sources"
          echo "  ios-test-automator server"
          echo "  ios-test-automator ui"
          echo ""
          echo "Configuration: ~/.ios-test-automator/.env"
          echo "Documentation: https://github.com/mheryerznkanyan/iOS-test-automator"
          ;;
        *)
          echo "Unknown command: $1"
          echo "Run 'ios-test-automator help' for usage information"
          exit 1
          ;;
      esac
    EOS

    # Create init script
    (bin/"ios-test-automator-init").write <<~EOS
      #!/bin/bash

      echo "🚀 iOS Test Automator - Initialization"
      echo ""

      CONFIG_DIR="$HOME/.ios-test-automator"
      mkdir -p "$CONFIG_DIR"
      mkdir -p "$CONFIG_DIR/rag_store"
      mkdir -p "$CONFIG_DIR/recordings"

      if [ ! -f "$CONFIG_DIR/.env" ]; then
        cat > "$CONFIG_DIR/.env" << 'ENV_EOF'
# iOS Test Automator Configuration

# Anthropic API Key (required)
# Get your key from: https://console.anthropic.com/
ANTHROPIC_API_KEY=

# Backend Configuration
BACKEND_PORT=8000
BACKEND_HOST=0.0.0.0

# RAG Configuration
RAG_PERSIST_DIR=$HOME/.ios-test-automator/rag_store
RAG_COLLECTION=ios_app
RAG_TOP_K=10

# Streamlit Configuration
STREAMLIT_PORT=8501

# Simulator Configuration (auto-detected if empty)
SIMULATOR_ID=
SIMULATOR_NAME=iPhone 17
ENV_EOF
        echo "✅ Created config file: $CONFIG_DIR/.env"
      else
        echo "✅ Config file already exists: $CONFIG_DIR/.env"
      fi

      echo ""
      echo "📦 Directory structure:"
      echo "   Config:     $CONFIG_DIR/.env"
      echo "   RAG Store:  $CONFIG_DIR/rag_store"
      echo "   Recordings: $CONFIG_DIR/recordings"
      echo ""
      echo "🎯 Next steps:"
      echo "   1. Add API key:    ios-test-automator config"
      echo "   2. Index your app: ios-test-automator rag ingest --app-dir /path/to/app"
      echo "   3. Start backend:  ios-test-automator server"
      echo "   4. Launch UI:      ios-test-automator ui"
      echo ""
    EOS

    chmod 0755, bin/"ios-test-automator"
    chmod 0755, bin/"ios-test-automator-init"
  end

  def caveats
    <<~EOS
      🎉 iOS Test Automator has been installed!

      Before using:
      1. Initialize: ios-test-automator init
      2. Add API key: ios-test-automator config
      3. Index your app: ios-test-automator rag ingest --app-dir /path/to/app

      Quick start:
        ios-test-automator server    # Terminal 1
        ios-test-automator ui         # Terminal 2
        open http://localhost:8501

      Documentation: https://github.com/mheryerznkanyan/iOS-test-automator
    EOS
  end

  test do
    # Test the CLI
    assert_match "iOS Test Automator", shell_output("#{bin}/ios-test-automator version")

    # Test Python installation
    system libexec/"bin/python", "-c", "import fastapi; import langchain_anthropic; import chromadb; import streamlit"
  end
end
