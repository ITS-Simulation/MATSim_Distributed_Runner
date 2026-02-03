#!/bin/bash
FILE="Dockerfile"
SOURCE_BRANCH="i7"
COMMIT_MSG="${1:-Update shared file}"

# Get current branch
CURRENT=$(git branch --show-current)

# Get all branches
BRANCHES=$(git branch --format='%(refname:short)' | grep -v "^$SOURCE_BRANCH$")

# Update file on source branch first
git checkout $SOURCE_BRANCH
git add $FILE
git commit -m "$COMMIT_MSG"

# Sync to all other branches
for BRANCH in $BRANCHES; do
    echo "Syncing to $BRANCH..."
    git checkout $BRANCH
    git checkout $SOURCE_BRANCH -- $FILE
    git commit -m "$COMMIT_MSG"
done

# Return to original branch
git checkout $CURRENT
echo "✓ File synced across all branches"