#!/bin/bash

dir="$1"
file="./$dir/$(date +%Y%m%d%H%M).md"

touch "$file"
cat <<EOL >> "$file"
echo ---
title:
date: $(date +%Y-%m-%d)
tags:
draft: false
---
EOL
