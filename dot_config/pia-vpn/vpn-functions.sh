vpnconnect() {
    # Configuration
    local repo_url="https://github.com/pia-foss/manual-connections.git"
    local commit_hash="e956c57"
    local temp_dir="/tmp/pia-vpn-$$-$(date +%s)"
    
    # Your preferred server IDs for quick selection
    declare -A servers=(
        ["fr"]="france"
        ["france"]="france"
        ["uk"]="uk"
        ["ch"]="swiss"
        ["swiss"]="swiss"
        ["es"]="spain"
        ["spain"]="spain"
        ["se"]="sweden"
        ["sweden"]="sweden"
        ["dk"]="denmark"
        ["denmark"]="denmark"
        ["ro"]="ro"
        ["romania"]="ro"
        ["no"]="no"
        ["norway"]="no"
        ["gl"]="greenland"
        ["greenland"]="greenland"
        ["us-east"]="us-newjersey"
        ["use"]="us-newjersey"
        ["us-west"]="us3"
        ["usw"]="us3"
        ["home"]="home"
    )
    
    # Check for required commands
    for cmd in git sudo; do
        if ! command -v $cmd &> /dev/null; then
            echo "Error: $cmd is not installed"
            return 1
        fi
    done
    
    # Trap to ensure cleanup happens even on interrupt (Ctrl+C)
    trap 'echo "Interrupted. Cleaning up..."; rm -rf "$temp_dir" 2>/dev/null; unset PIA_PASS; return 130' INT
    
    # Server selection
    echo "╔════════════════════════════════════════════╗"
    echo "║          PIA VPN Server Selection          ║"
    echo "╠════════════════════════════════════════════╣"
    echo "║ Europe:                                    ║"
    echo "║   fr/france    - France                    ║"
    echo "║   uk          - United Kingdom             ║"
    echo "║   ch/swiss    - Switzerland                ║"
    echo "║   es/spain    - Spain                      ║"
    echo "║   se/sweden   - Sweden                     ║"
    echo "║   dk/denmark  - Denmark                    ║"
    echo "║   ro/romania  - Romania                    ║"
    echo "║   no/norway   - Norway                     ║"
    echo "║   gl/greenland - Greenland                 ║"
    echo "║                                            ║"
    echo "║ United States:                             ║"
    echo "║   use/us-east - US East (New Jersey)       ║"
    echo "║   usw/us-west - US West                    ║"
    echo "║                                            ║"
    echo "║ Personal:                                  ║"
    echo "║   home        - Home Network (dreez.dk)    ║"
    echo "║                                            ║"
    echo "║ Other:                                     ║"
    echo "║   auto        - Auto (lowest latency)      ║"
    echo "║   [Enter]     - Manual selection from list ║"
    echo "╚════════════════════════════════════════════╝"
    echo
    echo -n "Enter server choice: "
    read -r server_choice
    
    # Convert to lowercase for matching
    server_choice=$(echo "$server_choice" | tr '[:upper:]' '[:lower:]')
    
    # Check if home network was selected
    if [[ "$server_choice" == "home" ]]; then
        _vpnconnect_home
        return $?
    fi
    
    # Set PREFERRED_REGION based on choice
    if [[ -n "$server_choice" ]]; then
        if [[ "$server_choice" == "auto" ]]; then
            PREFERRED_REGION=""
            AUTOCONNECT="true"
            echo -e "\n✓ Will auto-connect to lowest latency server"
        elif [[ -n "${servers[$server_choice]}" ]]; then
            PREFERRED_REGION="${servers[$server_choice]}"
            AUTOCONNECT="false"
            echo -e "\n✓ Selected region: $PREFERRED_REGION"
        else
            # Direct region ID input
            PREFERRED_REGION="$server_choice"
            AUTOCONNECT="false"
            echo -e "\n✓ Using custom region: $PREFERRED_REGION"
        fi
    else
        # Manual selection will be handled by the script
        AUTOCONNECT="false"
        echo -e "\n✓ Manual server selection will be shown"
    fi
    
    echo
    # Prompt for username if you want to make it configurable
    echo -n "Enter PIA username (or press Enter for default p8848822): "
    read PIA_USER
    PIA_USER=${PIA_USER:-p8848822}
    
    # Prompt for password securely
    echo -n "Enter PIA password: "
    read -s PIA_PASS
    echo
    
    # Validate password was entered
    if [ -z "$PIA_PASS" ]; then
        echo "Error: Password cannot be empty"
        return 1
    fi
    
    echo
    echo "Setting up VPN connection..."
    
    # Clone the repository quietly
    echo "→ Downloading PIA manual connections..."
    if ! git clone --quiet "$repo_url" "$temp_dir" 2>/dev/null; then
        echo "Error: Failed to clone repository"
        echo "Check your internet connection and try again"
        unset PIA_PASS
        return 1
    fi
    
    # Change to the temp directory
    cd "$temp_dir" || {
        echo "Error: Failed to access temporary directory"
        rm -rf "$temp_dir"
        unset PIA_PASS
        return 1
    }
    
    # Checkout specific commit
    echo "→ Verifying repository version..."
    if ! git checkout --quiet "$commit_hash" 2>/dev/null; then
        echo "Error: Failed to checkout commit $commit_hash"
        cd - > /dev/null
        rm -rf "$temp_dir"
        unset PIA_PASS
        return 1
    fi
    
    # Make sure the script is executable
    chmod +x run_setup.sh
    
    # Run the setup script with sudo
    echo "→ Connecting to VPN..."
    sudo VPN_PROTOCOL=wireguard \
         DISABLE_IPV6=yes \
         DIP_TOKEN=no \
         AUTOCONNECT="${AUTOCONNECT:-false}" \
         PREFERRED_REGION="$PREFERRED_REGION" \
         MAX_LATENCY="${MAX_LATENCY:-0.05}" \
         PIA_PF=false \
         PIA_DNS=true \
         PIA_USER="$PIA_USER" \
         PIA_PASS="$PIA_PASS" \
         ./run_setup.sh
    
    # Store the exit code
    local exit_code=$?
    
    # Clean up
    cd - > /dev/null
    echo "→ Cleaning up..."
    rm -rf "$temp_dir"
    
    # Clear sensitive variables
    unset PIA_PASS
    unset PIA_USER
    unset PREFERRED_REGION
    unset AUTOCONNECT
    
    # Remove the trap
    trap - INT
    
    if [ $exit_code -eq 0 ]; then
        echo
        echo "╔════════════════════════════════════════════╗"
        echo "║   ✓ VPN connection established!            ║"
        echo "╚════════════════════════════════════════════╝"
    else
        echo
        echo "╔═══════════════════════════════════════════════════╗"
        echo "║   ✗ VPN setup failed (exit code: $exit_code)      ║"
        echo "╚═══════════════════════════════════════════════════╝"
    fi
    
    return $exit_code
}

# Home network connection function (hidden from autocompletion)
_vpnconnect_home() {
    local config_full="/root/wireguard-keys/dreez-wg0-full.conf"
    local config_split="/root/wireguard-keys/dreez-wg0-split.conf"
    
    echo
    echo "╔════════════════════════════════════════════╗"
    echo "║       Home Network Connection Mode         ║"
    echo "╠════════════════════════════════════════════╣"
    echo "║ 1. Full Tunnel - Route all traffic         ║"
    echo "║    (Default - all internet through VPN)    ║"
    echo "║                                            ║"
    echo "║ 2. Split Tunnel - Local network only       ║"
    echo "║    (Only home network, direct internet)    ║"
    echo "╚════════════════════════════════════════════╝"
    echo
    echo -n "Select mode (1/2) [default: 1]: "
    read -r tunnel_mode
    tunnel_mode=${tunnel_mode:-1}
    
    # Select config based on tunnel mode
    if [ "$tunnel_mode" = "2" ]; then
        config_to_use="$config_split"
        mode_name="split tunnel mode (local network only)"
        
        # Check if split config exists
        if ! sudo test -f "$config_split"; then
            echo "Error: Split tunnel configuration file not found at $config_split"
            echo "Please create this file with AllowedIPs set to private networks only"
            return 1
        fi
    else
        config_to_use="$config_full"
        mode_name="full tunnel mode (all traffic)"
        
        # Check if full config exists
        if ! sudo test -f "$config_full"; then
            echo "Error: Full tunnel configuration file not found at $config_full"
            echo "Please create this file with AllowedIPs = 0.0.0.0/0"
            return 1
        fi
    fi
    
    echo -e "\n✓ Using $mode_name"
    
    # Connect using the selected config
    echo "→ Connecting to home network..."
    if sudo wg-quick up "$config_to_use"; then
        echo
        echo "╔════════════════════════════════════════════╗"
        echo "║   ✓ Connected to home network!             ║"
        echo "╚════════════════════════════════════════════╝"
        return 0
    else
        echo
        echo "╔═══════════════════════════════════════════╗"
        echo "║   ✗ Failed to connect to home network     ║"
        echo "╚═══════════════════════════════════════════╝"
        return 1
    fi
}

# Quick connect aliases for your most used servers
#alias vpn-fr='PREFERRED_REGION="france" AUTOCONNECT="false" vpnconnect'
#alias vpn-uk='PREFERRED_REGION="uk" AUTOCONNECT="false" vpnconnect'
#alias vpn-dk='PREFERRED_REGION="denmark" AUTOCONNECT="false" vpnconnect'
#alias vpn-no='PREFERRED_REGION="no" AUTOCONNECT="false" vpnconnect'
#alias vpn-use='PREFERRED_REGION="us-newjersey" AUTOCONNECT="false" vpnconnect'
#alias vpn-usw='PREFERRED_REGION="us3" AUTOCONNECT="false" vpnconnect'

# Disconnect function
vpndisconnect() {
    local disconnected=false
    
    echo "Disconnecting VPN..."
    
    # Try to disconnect PIA
    if sudo wg show pia &>/dev/null; then
        sudo wg-quick down pia
        disconnected=true
    fi
    
    # Try to disconnect home network connections
    # Check for dreez-wg0-full or dreez-wg0-split interfaces
    if sudo wg show dreez-wg0-full &>/dev/null; then
        sudo wg-quick down /root/wireguard-keys/dreez-wg0-full.conf
        disconnected=true
    fi
    
    if sudo wg show dreez-wg0-split &>/dev/null; then
        sudo wg-quick down /root/wireguard-keys/dreez-wg0-split.conf
        disconnected=true
    fi
    
    if [ "$disconnected" = true ]; then
        echo "✓ VPN disconnected"
    else
        echo "✓ No active VPN connections found"
    fi
}

# Status function to check current connection
vpnstatus() {
    local found_connection=false
    
    # Check PIA connection
    if sudo wg show pia &>/dev/null; then
        echo "✓ PIA VPN is connected"
        echo
        sudo wg show pia
        found_connection=true
    fi
    
    # Check home network connection
    for iface in $(sudo wg show interfaces 2>/dev/null); do
        if [[ "$iface" != "pia" ]]; then
            echo "✓ Home network VPN is connected (interface: $iface)"
            echo
            sudo wg show "$iface"
            found_connection=true
        fi
    done
    
    if [ "$found_connection" = false ]; then
        echo "✗ VPN is not connected"
    fi
}
