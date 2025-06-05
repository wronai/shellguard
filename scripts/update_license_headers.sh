#!/bin/bash
# update_license_headers.sh - update_license_headers.sh - Script to update license headers in shell scripts
#
# Copyright (c) 2025 WRONAI - Tom Sapletta
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# update_license_headers.sh - Script to update license headers in shell scripts
#


# License header template
read -r -d '' LICENSE_HEADER << 'EOL'
#!/bin/bash
# %s - %s
#
EOL

# Find all shell scripts in the project
echo "Updating license headers for shell scripts..."

find . -type f -name "*.sh" | while read -r file; do
    echo "Processing $file..."
    
    # Get the first line to check if it's a shell script
    first_line=$(head -n 1 "$file")
    
    if [[ "$first_line" == "#!/bin/bash"* ]]; then
        # Get the script name and description
        script_name=$(basename "$file")
        second_line=$(sed -n '2p' "$file")
        description=$(echo "$second_line" | sed -E 's/^# ?//')
        
        if [[ -z "$description" ]]; then
            description="Shell script"
        fi
        
        # Create a temporary file with the new header
        temp_file=$(mktemp)
        printf "$LICENSE_HEADER\n" "$script_name" "$description" > "$temp_file"
        
        # Skip the shebang and any existing license header
        tail -n +2 "$file" | 
            # Remove existing license header if it exists
            awk '/^# Copyright/,/limitations under the License/ { next } { print }' | 
            # Skip empty lines at the beginning
            awk '!f && /^[[:space:]]*$/ { next } { f=1; print }' >> "$temp_file"
        
        # Replace the original file
        mv "$temp_file" "$file"
        chmod +x "$file"
        echo "  ✓ Updated license header"
    else
        echo "  ✗ Not a shell script or missing shebang, skipping"
    fi
done

echo "Done updating license headers."
