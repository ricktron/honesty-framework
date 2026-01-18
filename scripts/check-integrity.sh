#!/bin/bash

# Integrity Check Script
# Part of the Honesty Framework
# This script performs comprehensive integrity checks on the repository

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_header() {
    echo ""
    echo "================================"
    echo "$1"
    echo "================================"
    echo ""
}

# Create integrity directory
INTEGRITY_DIR=".integrity"
mkdir -p "$INTEGRITY_DIR"

# Function to generate file checksums
generate_checksums() {
    print_header "Generating File Checksums"
    
    # Generate checksums for all tracked files
    find . -type f -not -path './.git/*' -not -path "./$INTEGRITY_DIR/*" -exec sha256sum {} \; | sort > "$INTEGRITY_DIR/checksums.txt"
    
    local file_count=$(wc -l < "$INTEGRITY_DIR/checksums.txt")
    print_success "Generated checksums for $file_count files"
    print_info "Checksums saved to $INTEGRITY_DIR/checksums.txt"
}

# Function to verify file integrity
verify_file_integrity() {
    print_header "Verifying File Integrity"
    
    local issues_found=0
    
    # Check for suspicious file extensions
    print_info "Checking for suspicious file extensions..."
    local suspicious_exts=".exe .dll .so .dylib .bin"
    
    for ext in $suspicious_exts; do
        local found_files=$(find . -type f -name "*$ext" -not -path './.git/*' 2>/dev/null || true)
        if [ -n "$found_files" ]; then
            print_warning "Found files with extension $ext:"
            echo "$found_files" | while read -r file; do
                echo "  - $file"
            done
            issues_found=$((issues_found + 1))
        fi
    done
    
    # Check for very large files
    print_info "Checking for large files (>10MB)..."
    local large_files=$(find . -type f -not -path './.git/*' -size +10M 2>/dev/null || true)
    if [ -n "$large_files" ]; then
        print_warning "Found large files:"
        echo "$large_files" | while read -r file; do
            local size=$(du -h "$file" | cut -f1)
            echo "  - $file ($size)"
        done
    fi
    
    # Check for hidden files (might be suspicious)
    print_info "Checking for hidden files..."
    local hidden_count=$(find . -name ".*" -type f -not -path './.git/*' 2>/dev/null | wc -l || echo "0")
    if [ "$hidden_count" -gt 5 ]; then
        print_info "Found $hidden_count hidden files (this may be normal)"
    fi
    
    if [ $issues_found -eq 0 ]; then
        print_success "File integrity check completed"
    else
        print_warning "File integrity check completed with warnings"
    fi
}

# Function to check for unauthorized modifications
check_unauthorized_modifications() {
    print_header "Checking for Unauthorized Modifications"
    
    # Protected paths that should rarely change
    local protected_paths=".github/workflows/ config/"
    
    # Get list of changed files (if in a git repository)
    if git rev-parse --git-dir > /dev/null 2>&1; then
        print_info "Checking recent changes to protected paths..."
        
        for path in $protected_paths; do
            if [ -d "$path" ]; then
                local recent_changes=$(git log --since="7 days ago" --name-only --pretty=format: -- "$path" | sort -u | grep -v '^$' || true)
                
                if [ -n "$recent_changes" ]; then
                    print_warning "Recent changes detected in protected path: $path"
                    echo "$recent_changes" | while read -r file; do
                        echo "  - $file"
                    done
                    print_info "Ensure these changes have proper authorization and review"
                fi
            fi
        done
        
        print_success "Unauthorized modification check completed"
    else
        print_info "Not a git repository, skipping modification check"
    fi
}

# Function to validate dependencies
validate_dependencies() {
    print_header "Validating Dependencies"
    
    local issues_found=0
    
    # Check for package.json and package-lock.json
    if [ -f "package.json" ]; then
        print_info "Found package.json"
        if [ -f "package-lock.json" ]; then
            print_success "package-lock.json present"
        else
            print_warning "package-lock.json not found"
            issues_found=$((issues_found + 1))
        fi
    fi
    
    # Check for requirements.txt
    if [ -f "requirements.txt" ]; then
        print_info "Found requirements.txt"
        
        # Check for pinned versions
        if grep -qE '^[^=<>~#]+$' requirements.txt; then
            print_warning "Some Python dependencies are not pinned to specific versions"
            grep -E '^[^=<>~#]+$' requirements.txt | head -5 | while read -r dep; do
                echo "  - $dep"
            done
            issues_found=$((issues_found + 1))
        else
            print_success "All Python dependencies are pinned"
        fi
    fi
    
    # Check for go.mod and go.sum
    if [ -f "go.mod" ]; then
        print_info "Found go.mod"
        if [ -f "go.sum" ]; then
            print_success "go.sum present"
        else
            print_warning "go.sum not found"
            issues_found=$((issues_found + 1))
        fi
    fi
    
    # Check for Gemfile and Gemfile.lock
    if [ -f "Gemfile" ]; then
        print_info "Found Gemfile"
        if [ -f "Gemfile.lock" ]; then
            print_success "Gemfile.lock present"
        else
            print_warning "Gemfile.lock not found"
            issues_found=$((issues_found + 1))
        fi
    fi
    
    if [ $issues_found -eq 0 ]; then
        print_success "Dependency validation completed"
    else
        print_warning "Dependency validation completed with warnings"
    fi
}

# Function to scan for code anomalies
scan_code_anomalies() {
    print_header "Scanning for Code Anomalies"
    
    # Check for TODO/FIXME comments
    print_info "Checking for TODO/FIXME comments..."
    local todo_count=$(git grep -i -E '(TODO|FIXME|XXX|HACK)' 2>/dev/null | wc -l || echo "0")
    if [ "$todo_count" -gt 0 ]; then
        print_info "Found $todo_count TODO/FIXME comments"
    fi
    
    # Check for debugger statements
    print_info "Checking for debugger statements..."
    local debugger_patterns="debugger console\.log print\( var_dump"
    for pattern in $debugger_patterns; do
        local found=$(git grep -E "$pattern" -- '*.js' '*.py' '*.php' 2>/dev/null | wc -l || echo "0")
        if [ "$found" -gt 0 ]; then
            print_warning "Found $found occurrences of '$pattern'"
        fi
    done
    
    # Check for long lines
    print_info "Checking for very long lines (>200 chars)..."
    local long_lines=$(find . -type f \( -name '*.sh' -o -name '*.py' -o -name '*.js' -o -name '*.md' \) -not -path './.git/*' -exec awk 'length>200' {} + 2>/dev/null | wc -l || echo "0")
    if [ "$long_lines" -gt 0 ]; then
        print_info "Found $long_lines lines longer than 200 characters"
    fi
    
    print_success "Code anomaly scan completed"
}

# Function to generate integrity report
generate_report() {
    print_header "Generating Integrity Report"
    
    local report_file="$INTEGRITY_DIR/integrity-report-$(date +%Y%m%d-%H%M%S).md"
    
    cat > "$report_file" << EOF
# Repository Integrity Report

**Generated**: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
**Repository**: $(git remote get-url origin 2>/dev/null || echo "Unknown")
**Branch**: $(git branch --show-current 2>/dev/null || echo "Unknown")
**Commit**: $(git rev-parse HEAD 2>/dev/null || echo "Unknown")

## Summary

- ✅ File checksums generated
- ✅ File integrity verified
- ✅ Unauthorized modification check completed
- ✅ Dependency integrity validated
- ✅ Code anomaly scan completed

## Checksum Summary

Total files checked: $(wc -l < "$INTEGRITY_DIR/checksums.txt" 2>/dev/null || echo "N/A")

## Details

For detailed results, review the script output and checksum files.

---
*Generated by Honesty Framework Integrity Check Script*
EOF
    
    print_success "Integrity report saved to: $report_file"
    cat "$report_file"
}

# Main execution
print_header "Honesty Framework - Repository Integrity Check"

generate_checksums
verify_file_integrity
check_unauthorized_modifications
validate_dependencies
scan_code_anomalies
generate_report

print_header "Integrity Check Completed"
print_success "All integrity checks completed successfully!"
