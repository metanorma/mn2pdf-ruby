# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

mn2pdf-ruby is a Ruby gem wrapper around the Java mn2pdf library (mn2pdf.jar) for converting Metanorma XML files into PDF. The gem version mirrors the underlying mn2pdf.jar version.

## Common Commands

```bash
# Install dependencies
bundle install

# Run all tests (also downloads bin/mn2pdf.jar if missing)
rake

# Run tests only
rake spec

# Download/update the mn2pdf.jar to match version in lib/mn2pdf/version.rb
rake bin/mn2pdf.jar

# Run a single spec file
rspec spec/mn2pdf_spec.rb

# Run a specific test
rspec spec/mn2pdf_spec.rb -e "converts XML to PDF"

# Release the gem
rake release
```

## Architecture

- `lib/mn2pdf.rb` - Main module exposing `Mn2pdf.convert()`, `Mn2pdf.help()`, and `Mn2pdf.version()`. Handles argument building, font manifest processing, and error parsing.
- `lib/mn2pdf/jvm.rb` - JVM wrapper that invokes the Java JAR with appropriate heap (-Xmx3g), stack (-Xss10m), and headless options.
- `lib/mn2pdf/version.rb` - Contains `VERSION` (gem version) and `MN2PDF_JAR_VERSION` (JAR version). These must be kept in sync.
- `bin/mn2pdf.jar` - The mn2pdf Java JAR, downloaded via `rake bin/mn2pdf.jar`.

## Updating mn2pdf Version

1. Update `VERSION` and `MN2PDF_JAR_VERSION` in `lib/mn2pdf/version.rb` to the desired version
2. Run `rake bin/mn2pdf.jar` to verify the JAR downloads successfully
3. Commit and release with `rake release`
