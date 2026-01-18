#!/bin/bash

# Commit Verification Script
# Part of the Honesty Framework
# This script verifies commit integrity and format

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
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
    echo -e "ℹ️  $1"
}

# Function to verify commit message format
verify_commit_message() {
    local commit_sha=$1
    local commit_msg=$(git log --format=%B -n 1 "$commit_sha")
    
    echo ""
    echo "Verifying commit message for: $commit_sha"
    echo "Message: $commit_msg"
    echo ""
    
    # Check if message is not empty
    if [ -z "$commit_msg" ]; then
        print_error "Commit message is empty"
        return 1
    fi
    
    # Check minimum length
    local msg_length=${#commit_msg}
    if [ $msg_length -lt 10 ]; then
        print_warning "Commit message is very short ($msg_length chars)"
        print_info "Consider providing more context"
    fi
    
    # Check for conventional commit format (optional)
    if echo "$commit_msg" | grep -qE '^(feat|fix|docs|style|refactor|test|chore|perf|ci|build|revert)(\(.+\))?: .+'; then
        print_success "Commit follows conventional commit format"
    else
        print_info "Commit does not follow conventional commit format (optional)"
    fi
    
    print_success "Commit message verified"
    return 0
}

# Function to check for sensitive data
check_sensitive_data() {
    local commit_sha=$1
    
    echo ""
    echo "Scanning for sensitive data in commit: $commit_sha"
    echo ""
    
    # Patterns to check for sensitive data
    local patterns=(
        "password[[:space:]]*=[[:space:]]*[^\n\r]{1,}"
        "api[_-]?key[[:space:]]*=[[:space:]]*[^\n\r]{1,}"
        "secret[[:space:]]*=[[:space:]]*[^\n\r]{1,}"
        "token[[:space:]]*=[[:space:]]*[^\n\r]{1,}"
        "private[_-]?key"
        "BEGIN.*PRIVATE KEY"
        "aws_access_key_id"
        "aws_secret_access_key"
    )
    
    local found_sensitive=0
    
    for pattern in "${patterns[@]}"; do
        if git show "$commit_sha" | grep -iE "$pattern" | grep -v "^-" | grep -v "#" >/dev/null 2>&1; then
            print_error "Potential sensitive data found matching pattern: $pattern"
            found_sensitive=1
        fi
    done
    
    if [ $found_sensitive -eq 0 ]; then
        print_success "No sensitive data detected"
        return 0
    else
        print_error "Sensitive data check FAILED"
        return 1
    fi
}

# Function to verify author identity
verify_author() {
    local commit_sha=$1
    
    echo ""
    echo "Verifying author identity for commit: $commit_sha"
    echo ""
    
    local author_email=$(git log -1 --pretty=format:"%ae" "$commit_sha")
    local author_name=$(git log -1 --pretty=format:"%an" "$commit_sha")
    
    echo "Author: $author_name <$author_email>"
    
    # Verify email format
    if ! echo "$author_email" | grep -qE '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'; then
        print_error "Invalid email format: $author_email"
        return 1
    fi
    
    # Verify author name is not empty
    if [ -z "$author_name" ]; then
        print_error "Author name is empty"
        return 1
    fi
    
    # Check for generic/placeholder names
    if echo "$author_name" | grep -qiE '^(user|author|developer|test|unknown)$'; then
        print_warning "Author name appears to be generic: $author_name"
    fi
    
    print_success "Author identity verified"
    return 0
}

# Function to check commit signature
check_signature() {
    local commit_sha=$1
    
    echo ""
    echo "Checking commit signature for: $commit_sha"
    echo ""
    
    local signature_status=$(git log -1 --pretty=format:"%G?" "$commit_sha")
    
    case "$signature_status" in
        G)
            print_success "Commit is signed with a valid signature"
            return 0
            ;;
        B)
            print_warning "Commit has a bad signature"
            ;;
        U)
            print_warning "Commit has a good signature but untrusted"
            ;;
        X)
            print_warning "Commit signature has expired"
            ;;
        Y)
            print_warning "Commit signature made by expired key"
            ;;
        R)
            print_warning "Commit signature made by revoked key"
            ;;
        N)
            print_info "Commit is not signed (signing is recommended but not required)"
            return 0
            ;;
        *)
            print_info "Unknown signature status: $signature_status"
            return 0
            ;;
    esac
    
    return 0
}

# Main verification function
verify_commit() {
    local commit_sha=$1
    local failed=0
    
    echo "="
echo "="
    echo "Honesty Framework - Commit Verification"
    echo "="
echo "="
    echo ""
    
    # Run all verification checks
    verify_commit_message "$commit_sha" || failed=1
    check_sensitive_data "$commit_sha" || failed=1
    verify_author "$commit_sha" || failed=1
    check_signature "$commit_sha" || failed=1
    
    echo ""
    echo "="
echo "="
    
    if [ $failed -eq 0 ]; then
        print_success "All verification checks passed!"
        return 0
    else
        print_error "Some verification checks failed"
        return 1
    fi
}

# Main script execution
if [ $# -eq 0 ]; then
    # Verify last commit if no arguments
    COMMIT_SHA="HEAD"
else
    COMMIT_SHA="$1"
fi

verify_commit "$COMMIT_SHA"
exit $?
