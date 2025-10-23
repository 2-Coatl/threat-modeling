#!/usr/bin/env bash
# infrastructure/scripts/test-plantweb.sh
# Test Plantweb installation and functionality

set -euo pipefail

# =============================================================================
# COLORS
# =============================================================================

if [[ -t 1 ]]; then
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m'
else
    GREEN=''
    RED=''
    YELLOW=''
    BLUE=''
    NC=''
fi

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

print_test() {
    echo -e "${BLUE}[TEST $1]${NC} $2"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_header() {
    echo ""
    echo "============================================================"
    echo "  $1"
    echo "============================================================"
}

# =============================================================================
# TEST FUNCTIONS
# =============================================================================

test_plantweb_command() {
    print_test "1" "Checking plantweb command..."

    if command -v plantweb &> /dev/null; then
        local version
        version=$(plantweb --version 2>&1 || echo "unknown")
        print_success "plantweb command found: $version"
        return 0
    else
        print_error "plantweb command not found"
        return 1
    fi
}

test_python_import() {
    print_test "2" "Testing Python imports..."

    local test_script="
import sys
sys.path.insert(0, '/vagrant')

try:
    # Test plantweb package
    import plantweb
    print(f'[OK] plantweb package: {plantweb.__version__}')

    # Test our module
    from api.plantweb import render, configure
    print('[OK] api.plantweb module')

    # Test submodules
    from api.plantweb.config import get_config
    from api.plantweb.renderer import encode_plantuml
    from api.plantweb.cache import get_cache_stats
    from api.plantweb.pytm_adapter import render_pytm_seq
    print('[OK] All submodules importable')

except ImportError as e:
    print(f'[ERROR] Import failed: {e}')
    sys.exit(1)
"

    if python3 -c "$test_script"; then
        print_success "All Python imports successful"
        return 0
    else
        print_error "Python import failed"
        return 1
    fi
}

test_server_connectivity() {
    print_test "3" "Testing PlantUML Server connectivity..."

    local server_url="${PLANTUML_SERVER:-http://localhost:8080/plantuml}"

    echo "  Server: $server_url"

    if curl -sf --max-time 5 "${server_url}" &> /dev/null; then
        print_success "Server accessible at: $server_url"
        return 0
    else
        print_error "Server not accessible at: $server_url"
        print_warning "Make sure PlantUML Server is running:"
        echo "    sudo systemctl start plantuml"
        return 1
    fi
}

test_module_configuration() {
    print_test "4" "Testing module configuration..."

    local test_script="
import sys
sys.path.insert(0, '/vagrant')

from api.plantweb import get_config, configure

# Get default config
config = get_config()
print(f'[OK] Server URL: {config[\"server_url\"]}')
print(f'[OK] Cache dir: {config[\"cache_dir\"]}')
print(f'[OK] Format: {config[\"format\"]}')
print(f'[OK] Use cache: {config[\"use_cache\"]}')

# Test configuration
configure(format='png')
config = get_config()
assert config['format'] == 'png', 'Configuration not applied'
print('[OK] Configuration changes work')
"

    if python3 -c "$test_script"; then
        print_success "Module configuration works"
        return 0
    else
        print_error "Module configuration failed"
        return 1
    fi
}

test_simple_rendering() {
    print_test "5" "Testing simple diagram rendering..."

    local test_file="/tmp/plantweb_test_$$.uml"
    local output_file="/tmp/plantweb_test_$$.svg"

    # Create test diagram
    cat > "$test_file" << 'EOF'
@startuml
Alice -> Bob: Authentication Request
Bob --> Alice: Authentication Response
@enduml
EOF

    local test_script="
import sys
sys.path.insert(0, '/vagrant')

from api.plantweb import render_file

try:
    result = render_file('$test_file', '$output_file')
    print(f'[OK] Rendered to: {result}')
except Exception as e:
    print(f'[ERROR] Rendering failed: {e}')
    sys.exit(1)
"

    if python3 -c "$test_script"; then
        if [[ -f "$output_file" ]]; then
            local size
            size=$(stat -c%s "$output_file" 2>/dev/null || stat -f%z "$output_file" 2>/dev/null)
            print_success "Diagram rendered successfully ($size bytes)"

            # Cleanup
            rm -f "$test_file" "$output_file"
            return 0
        else
            print_error "Output file not created"
            rm -f "$test_file"
            return 1
        fi
    else
        print_error "Rendering failed"
        rm -f "$test_file"
        return 1
    fi
}

test_cache_functionality() {
    print_test "6" "Testing cache functionality..."

    local test_script="
import sys
sys.path.insert(0, '/vagrant')

from api.plantweb import get_cache_stats, clear_cache
from api.plantweb.cache import get_cached, save_to_cache

# Get stats
stats = get_cache_stats()
print(f'[OK] Cache enabled: {stats[\"enabled\"]}')
print(f'[OK] Cache dir: {stats[\"cache_dir\"]}')
print(f'[OK] Total files: {stats[\"total_files\"]}')

# Test save/retrieve
test_content = '@startuml\\nTest\\n@enduml'
test_data = b'test data'

save_to_cache(test_content, 'svg', test_data)
retrieved = get_cached(test_content, 'svg')

if retrieved == test_data:
    print('[OK] Cache save/retrieve works')
else:
    print('[ERROR] Cache retrieve failed')
    sys.exit(1)
"

    if python3 -c "$test_script"; then
        print_success "Cache functionality works"
        return 0
    else
        print_error "Cache functionality failed"
        return 1
    fi
}

test_cli_wrapper() {
    print_test "7" "Testing CLI wrapper..."

    local wrapper_path="/vagrant/infrastructure/bin/plantweb-render"

    if [[ ! -f "$wrapper_path" ]]; then
        print_error "CLI wrapper not found: $wrapper_path"
        return 1
    fi

    if [[ ! -x "$wrapper_path" ]]; then
        print_error "CLI wrapper not executable"
        return 1
    fi

    # Test help
    if "$wrapper_path" --help &> /dev/null; then
        print_success "CLI wrapper works"
        return 0
    else
        print_error "CLI wrapper execution failed"
        return 1
    fi
}

test_pytm_integration() {
    print_test "8" "Testing pytm integration..."

    local test_script="
import sys
sys.path.insert(0, '/vagrant')

try:
    from pytm import TM, Actor, Server, Dataflow
    from api.plantweb import extract_plantuml_from_pytm

    # Create simple model
    tm = TM('Test')
    actor = Actor('User')
    server = Server('App')
    flow = Dataflow(actor, server, 'Request')

    # Extract PlantUML
    code = extract_plantuml_from_pytm(tm, 'seq')

    if code and len(code) > 10:
        print('[OK] PlantUML extracted from pytm')
        print(f'  Length: {len(code)} chars')
    else:
        print('[ERROR] Extraction failed')
        sys.exit(1)

except Exception as e:
    print(f'[ERROR] pytm integration failed: {e}')
    sys.exit(1)
"

    if python3 -c "$test_script"; then
        print_success "pytm integration works"
        return 0
    else
        print_error "pytm integration failed"
        return 1
    fi
}

# =============================================================================
# MAIN TEST SUITE
# =============================================================================

main() {
    print_header "Plantweb Test Suite"

    local total_tests=8
    local passed_tests=0
    local failed_tests=0

    # Run tests
    test_plantweb_command && ((passed_tests++)) || ((failed_tests++))
    echo ""

    test_python_import && ((passed_tests++)) || ((failed_tests++))
    echo ""

    test_server_connectivity && ((passed_tests++)) || ((failed_tests++))
    echo ""

    test_module_configuration && ((passed_tests++)) || ((failed_tests++))
    echo ""

    test_simple_rendering && ((passed_tests++)) || ((failed_tests++))
    echo ""

    test_cache_functionality && ((passed_tests++)) || ((failed_tests++))
    echo ""

    test_cli_wrapper && ((passed_tests++)) || ((failed_tests++))
    echo ""

    test_pytm_integration && ((passed_tests++)) || ((failed_tests++))
    echo ""

    # Summary
    print_header "Test Results"

    echo "Total tests:  $total_tests"
    echo -e "Passed:       ${GREEN}${passed_tests}${NC}"

    if [[ $failed_tests -gt 0 ]]; then
        echo -e "Failed:       ${RED}${failed_tests}${NC}"
        echo ""
        echo -e "${RED}Some tests failed${NC}"
        return 1
    else
        echo ""
        echo -e "${GREEN}All tests passed!${NC}"
        return 0
    fi
}

# =============================================================================
# EXECUTION
# =============================================================================

main "$@"
exit $?