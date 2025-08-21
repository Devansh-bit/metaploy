#!/bin/bash
# Metaploy setup script

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

usage() {
    echo "Usage: $0 [http|https] [start|stop|restart|logs]"
    echo ""
    echo "Examples:"
    echo "  $0 http start    # Start in HTTP-only mode"
    echo "  $0 https start   # Start with HTTPS and SSL certificate generation"
    echo "  $0 https stop    # Stop HTTPS services"
    echo "  $0 logs          # Show logs"
    echo ""
    exit 1
}

if [[ $# -lt 1 ]]; then
    usage
fi

MODE="$1"
ACTION="${2:-start}"

case "$MODE" in
    "http")
        echo "🚀 Starting Metaploy in HTTP-only mode..."
        export METAPLOY_HTTPS_ENABLED=false
        case "$ACTION" in
            "start")
                docker-compose up -d nginx
                ;;
            "stop")
                docker-compose down
                ;;
            "restart")
                docker-compose restart nginx
                ;;
            "logs")
                docker-compose logs -f nginx
                ;;
            *)
                usage
                ;;
        esac
        ;;
    "https")
        echo "🔒 Starting Metaploy in HTTPS mode with SSL certificate generation..."
        export METAPLOY_HTTPS_ENABLED=true
        case "$ACTION" in
            "start")
                docker-compose --profile https up -d
                echo ""
                echo "✅ Metaploy started in HTTPS mode!"
                echo "📋 When you add .metaploy.conf files, SSL certificates will be automatically generated."
                echo "📊 Monitor logs: docker-compose logs -f metaploy"
                ;;
            "stop")
                docker-compose --profile https down
                ;;
            "restart")
                docker-compose --profile https restart
                ;;
            "logs")
                docker-compose --profile https logs -f
                ;;
            *)
                usage
                ;;
        esac
        ;;
    "logs")
        docker-compose logs -f
        ;;
    *)
        usage
        ;;
esac

if [[ "$ACTION" == "start" ]]; then
    echo ""
    echo "📁 To add a new project:"
    echo "   1. Create your project.metaploy.conf file"
    echo "   2. Mount it in your project's docker-compose:"
    echo "      volumes:"
    echo "        - ./project.metaploy.conf:/etc/nginx/sites-enabled/project.metaploy.conf:ro"
    echo "   3. Connect your project to the metaploy-network"
    echo ""
    if [[ "$MODE" == "https" ]]; then
        echo "🔐 SSL certificates will be automatically generated for domains in your server_name directives!"
    fi
fi