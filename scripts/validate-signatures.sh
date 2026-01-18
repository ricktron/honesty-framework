#!/bin/bash

# Signature Validation Script
# Part of the Honesty Framework
# This script validates commit signatures in the repository

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

# Function to check if git is available
check_git() {
    if ! command -v git &> /dev/null; then
        print_error "Git is not installed"
        exit 1
    fi
    
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "Not a git repository"
        exit 1
    fi
}

# Function to validate a single commit signature
validate_commit_signature() {
    local commit_sha=$1
    local commit_subject=$(git log -1 --pretty=format:"%s" "$commit_sha")
    local author=$(git log -1 --pretty=format:"%an" "$commit_sha")
    local signature_status=$(git log -1 --pretty=format:"%G?" "$commit_sha")
    local signer=$(git log -1 --pretty=format:"%GS" "$commit_sha")
    
    echo "Commit: ${commit_sha:0:8} - $commit_subject"
    echo "Author: $author"
    
    case "$signature_status" in
        G)
            print_success "Valid signature from: $signer"
            return 0
            ;;
        B)
            print_error "Bad signature"
            return 1
            ;;
        U)
            print_warning "Good signature but untrusted: $signer"
            return 2
            ;;
        X)
            print_warning "Signature has expired"
            return 2
            ;;
        Y)
            print_warning "Signature made by expired key"
            return 2
            ;;
        R)
            print_error "Signature made by revoked key"
            return 1
            ;;
        N)
            print_info "Not signed"
            return 3
            ;;
        *)
            print_info "Unknown signature status: $signature_status"
            return 3
            ;;
    esac
}

# Function to validate signatures for a range of commits
validate_commit_range() {
    local commit_range=$1
    
    local total=0
    local signed=0
    local valid=0
    local invalid=0
    local unsigned=0
    local warnings=0
    
    print_header "Validating Commit Signatures"
    print_info "Checking commits: $commit_range"
    echo ""
    
    # Get list of commits
    local commits=$(git log --pretty=format:"%H" "$commit_range")
    
    for commit in $commits; do
        total=$((total + 1))
        echo "---"
        
        validate_commit_signature "$commit"
        local result=$?
        
        case $result in
            0)
                valid=$((valid + 1))
                signed=$((signed + 1))
                ;;
            1)
                invalid=$((invalid + 1))
                signed=$((signed + 1))
                ;;
            2)
                warnings=$((warnings + 1))
                signed=$((signed + 1))
                ;;
            3)
                unsigned=$((unsigned + 1))
                ;;
        esac
        
        echo ""
    done
    
    # Print summary
    print_header "Signature Validation Summary"
    echo "Total commits checked: $total"
    echo "Signed commits: $signed"
    echo "  ✅ Valid signatures: $valid"
    if [ $warnings -gt 0 ]; then
        echo "  ⚠️  Warnings: $warnings"
    fi
    if [ $invalid -gt 0 ]; then
        echo "  ❌ Invalid signatures: $invalid"
    fi
    echo "Unsigned commits: $unsigned"
    echo ""
    
    if [ $total -gt 0 ]; then
        local signed_percent=$((signed * 100 / total))
        echo "Signature coverage: $signed_percent%"
    fi
    
    echo ""
    
    # Return status based on results
    if [ $invalid -gt 0 ]; then
        print_error "Found commits with invalid signatures"
        return 1
    elif [ $warnings -gt 0 ]; then
        print_warning "Found commits with signature warnings"
        return 2
    elif [ $unsigned -eq $total ]; then
        print_info "No commits are signed (signing is recommended)"
        return 0
    else
        print_success "All signed commits have valid signatures"
        return 0
    fi
}

# Function to show GPG key information
show_gpg_info() {
    print_header "GPG Configuration"
    
    if command -v gpg &> /dev/null; then
        print_info "GPG is installed"
        
        local git_signing_key=$(git config --get user.signingkey 2>/dev/null || echo "")
        if [ -n "$git_signing_key" ]; then
            print_info "Git signing key configured: $git_signing_key"
        else
            print_warning "No Git signing key configured"
        fi
        
        local commit_gpgsign=$(git config --get commit.gpgsign 2>/dev/null || echo "false")
        if [ "$commit_gpgsign" = "true" ]; then
            print_info "Automatic commit signing: enabled"
        else
            print_info "Automatic commit signing: disabled"
        fi
    else
        print_warning "GPG is not installed"
    fi
}

# Function to show help message
show_help() {
    cat << EOF
Signature Validation Script
Part of the Honesty Framework

Usage: $0 [OPTIONS] [COMMIT_RANGE]

Options:
  -h, --help     Show this help message
  -i, --info     Show GPG configuration information
  -a, --all      Validate all commits in the repository
  -n NUM         Validate last NUM commits (default: 10)

Commit Range:
  You can specify a git commit range, for example:
  - HEAD~10..HEAD  (last 10 commits)
  - main..develop  (commits in develop not in main)
  - abc123..def456 (specific commit range)

Examples:
  $0                    # Validate last 10 commits
  $0 -n 20              # Validate last 20 commits
  $0 -a                 # Validate all commits
  $0 main..develop      # Validate commits in develop
  $0 --info             # Show GPG information

EOF
}

# Main execution
check_git

# Parse command line arguments
COMMIT_COUNT=10
COMMIT_RANGE=""
SHOW_INFO=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -i|--info)
            SHOW_INFO=true
            shift
            ;;
        -a|--all)
            COMMIT_RANGE="--all"
            shift
            ;;
        -n)
            COMMIT_COUNT="$2"
            shift 2
            ;;
        *)
            COMMIT_RANGE="$1"
            shift
            ;;
    esac
done

# Show GPG info if requested
if [ "$SHOW_INFO" = true ]; then
    show_gpg_info
    echo ""
fi

# Determine commit range
if [ -z "$COMMIT_RANGE" ]; then
    COMMIT_RANGE="HEAD~${COMMIT_COUNT}..HEAD"
    print_info "No commit range specified, using: $COMMIT_RANGE"
fi

# Validate signatures
validate_commit_range "$COMMIT_RANGE"
exit_code=$?

# Provide recommendations
if [ $exit_code -ne 0 ] || [ "$SHOW_INFO" = true ]; then
    echo ""
    print_header "Recommendations"
    
    if ! command -v gpg &> /dev/null; then
        echo "1. Install GPG: https://gnupg.org/download/"
    fi
    
    local git_signing_key=$(git config --get user.signingkey 2>/dev/null || echo "")
    if [ -z "$git_signing_key" ]; then
        echo "2. Generate a GPG key: gpg --gen-key"
        echo "3. Configure Git to use your key: git config --global user.signingkey YOUR_KEY_ID"
    fi
    
    local commit_gpgsign=$(git config --get commit.gpgsign 2>/dev/null || echo "false")
    if [ "$commit_gpgsign" != "true" ]; then
        echo "4. Enable automatic signing: git config --global commit.gpgsign true"
    fi
    
    echo "5. Add your GPG key to GitHub: Settings > SSH and GPG keys"
    echo ""
fi

exit $exit_code
